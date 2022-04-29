classdef setII
    %objeto desarrollado para Pregunta II.

    properties
        tabla
        idx
        prom_simce
        obs
        regresores
    end

    methods
        function obj = setII(base1,base2)
            %Constructor Tabla de datos para posterior procesamiento
            simce =readtable(base1);
            prior = readtable(base2);
            obj.tabla = innerjoin(simce,prior);
            obj.idx = struct();
            obj.idx.rbd = 3;
            obj.idx.cod_depe2 = 15;
            obj.idx.grupo = 16;
            obj.idx.rural = 17;
            obj.idx.prom_len = 21;
            obj.idx.prom_mat = 22;
            obj.idx.prom_css = 23;
            obj.idx.prom_prio = 45;
            obj.tabla = obj.tabla(:,[obj.idx.rbd obj.idx.cod_depe2 obj.idx.grupo obj.idx.rural ...
                obj.idx.prom_len obj.idx.prom_mat obj.idx.prom_css obj.idx.prom_prio]);
            %variables con nan
            obj.tabla=obj.tabla(~any(ismissing(obj.tabla),2),:);
            obj.prom_simce = mean(obj.tabla{:,["prom_lect8b_rbd" "prom_mate8b_rbd" "prom_soc8b_rbd"]},2);
            obj.obs = size(obj.tabla,1);
            obj.regresores = [ones(obj.obs,1) obj.tabla{:,["cod_depe2" "cod_grupo" "cod_rural_rbd" "prom_prioritario"]}];
        end
        function [coef, est_sigma] = mco_est(obj,regresores)
            mco = @(Y,X) (X'*X)\(X'*Y);
            coef = mco(obj.prom_simce ,regresores );
            err_est = obj.prom_simce - regresores*coef;
            est_sigma = sqrt((err_est'*err_est)/(obj.obs - size(regresores,2)));
            
        end


    end
end