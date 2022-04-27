classdef PreguntaI
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

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
    end

    methods
        function obj = PreguntaI(beta,delta,N,var_v,var_e)
            obj.beta = beta;
            obj.delta = delta;
            obj.var_v=var_v;
            obj.var_e=var_e;
            obj.N = N;
            obj.X1 = randn(N,1);
            obj.X2 = 2 * obj.X1 + sqrt(var_v) * randn(N,1);
            obj.X3 = randn(N,1);
            obj.U = repmat(delta(1),N,1) + delta(2)*obj.X2 + delta(3)*obj.X3 + sqrt(var_e)*randn(N,1);
            obj.Y = repmat(beta(1),N,1) + beta(2)*obj.X1+beta(3)*obj.X2+beta(4)*obj.X3 + obj.U; 
        end

        function [coef, err_st] = PreguntaI_est(obj,bool_cte,regresores)
            if bool_cte
                regresores = [ones(obj.N,1) regresores];
            end
            mco = @(Y,X) (X'*X)\(X'*Y);
            coef = mco(obj.Y ,regresores );
            err_st = obj.Y - regresores*coef;
        end
        function [test_t_est ] = testt(obj,bool_cte,regresores)
            test_t_est = zeros(2,1);
            [coef, err_st] = PreguntaI_est(obj,bool_cte,regresores);
            var_est = (err_st'*err_st) / (obj.N - 4);
            mat_varcov = (var_est^2) * (inv((regresores') * regresores)) ;
            test_t_est(1)= coef(2) / mat_varcov(2,2);
            test_t_est(2)= coef(3) / mat_varcov(3,3);
            %test_f = ([coef(2); coef(3)] \) * [coef(2) , coef(3)]
                
        end


    end
end