classdef PreguntaI
    %objeto pensado en responder a la pregunta I. El metodo PreguntaI_est
    %es usado para realizar las estimaciones solicitados retornando los
    %coeficientes y los respectivos errores estándar.

    properties
        Y
        X1
        X2
        X3
        U
        N
        beta
        delta
        var_v
        var_e
        e
        v
    end

    methods
        function obj = PreguntaI(beta,delta,N,var_v,var_e)
            rng(1)
            obj.beta = beta;
            obj.delta = delta;
            obj.var_v=var_v;
            obj.var_e=var_e;
            obj.e = sqrt(var_e)*randn(N,1);
            obj.v =  sqrt(var_v) * randn(N,1);           
            obj.N = N;
            obj.X1 = randn(N,1);
            obj.X2 = 2 * obj.X1 +obj.v;
            obj.X3 = randn(N,1);
            obj.U = repmat(delta(1),N,1) + delta(2)*obj.X2 + delta(3)*obj.X3 + obj.e;
            obj.Y = repmat(beta(1),N,1) + beta(2)*obj.X1+beta(3)*obj.X2+beta(4)*obj.X3 + obj.U; 
        end

        function [coef, err_st] = PreguntaI_est(obj,regresores)
            mco = @(Y,X) (X'*X)\(X'*Y);
            coef = mco(obj.Y ,regresores );
            err_st = obj.Y - regresores*coef;
        end
        function [test_t_est , test_f] = tests(obj,regresores)
            test_t_est = zeros(2,1);
            [coef, err_st ] = PreguntaI_est(obj,regresores);
%             matriz_white = (obj.N/ (obj.N - size(regresores,2)))* ...
%                 ((regresores'*regresores)\((regresores.*err_st)'*(regresores.*err_st))) ...
%                 / (regresores'*regresores);
%              test_t_est(1) = coef(2)/ sqrt(matriz_white(2,2));
%              test_t_est(2) = coef(3)/ sqrt(matriz_white(3,3));

           est_sigma = (err_st'*err_st) / (obj.N - size(regresores,2));
           mat_var_cov = est_sigma * (regresores'*regresores)^(-1);
           test_t_est(1) = coef(2)/ sqrt(mat_var_cov(2,2));
           test_t_est(2) = coef(3)/ sqrt(mat_var_cov(3,3));
           R = [0 0; 1 0 ; 0 1; 0 0];
           test_f = (R'*coef)' / (R' /  inv(regresores'*regresores) * R) * (R'*coef);

%             test_f = ( [coef(2); coef(3) ]' \ ( (est_sigma* [1 0 0 0; 0 1 0 0]'...
%                 \ (regresores'*regresores) ) *  [1 0 0 0; 0 1 0 0] ) )/2;    

        end
    end
end