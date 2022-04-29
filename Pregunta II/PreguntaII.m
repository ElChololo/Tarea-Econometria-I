classdef PreguntaII
    %objeto desarrollado para Pregunta II.

    properties
        tabla
        struc_idx
        prom_simce 
        regresores
    end

    methods
        function obj = PreguntaII(base1,base2)
            %Constructor Tabla de datos para posterior procesamiento
            simce =readmatrix(base1);
            prior = readmatrix(base2);
            prior(5978,2)=0;
            obj.struc_idx = struct();
            obj.struc_idx.rbd = 3;
            obj.struc_idx.cod_depe2 = 15;
            obj.struc_idx.grupo = 16;
            obj.struc_idx.rural = 17;
            obj.struc_idx.prom_len = 21;
            obj.struc_idx.prom_mat = 22;
            obj.struc_idx.prom_css = 23;
            obj.struc_idx.rbd_2 = 45;
            obj.struc_idx.prom_prio = 46;
            merged_matrix = cat(2,simce,prior);
            key_to_join = ismember(prior(:,1),simce(:,obj.struc_idx.rbd));
            inner_join = merged_matrix(key_to_join,:);
            %número de filas comprobadas con innerjoin de las tablas de
            %matlab
            %observaciones sin datos
            looking_nan_in = inner_join(:,[obj.struc_idx.rbd obj.struc_idx.cod_depe2 obj.struc_idx.grupo...
                obj.struc_idx.rural obj.struc_idx.prom_len obj.struc_idx.prom_mat obj.struc_idx.prom_css obj.struc_idx.prom_prio]);
            nan_in_row = sum(isnan(looking_nan_in),2)==0;
            obj.tabla =inner_join(nan_in_row,:);
            
        end

        function [est_desc , est_desc_cat]=est_desc(obj)
            var_relevantes_num = obj.tabla(:,[obj.struc_idx.prom_len ...
                obj.struc_idx.prom_mat obj.struc_idx.prom_css obj.struc_idx.prom_prio]);
            est_desc=[mean(var_relevantes_num); std(var_relevantes_num); min(var_relevantes_num); max(var_relevantes_num);]';
            var_relevante_cat_1 = obj.tabla(obj.tabla(:,obj.struc_idx.cod_depe2)==1,...
                [obj.struc_idx.prom_len obj.struc_idx.prom_mat obj.struc_idx.prom_css obj.struc_idx.prom_prio]);
            est_desc_cat=[mean(var_relevante_cat_1); std(var_relevante_cat_1); min(var_relevante_cat_1); max(var_relevante_cat_1);]';

        end

        function [coef, est_sigma] = PreguntaII_est(obj,regresores)
            mco = @(Y,X) (X'*X)\(X'*Y);
            coef = mco(obj.Y ,regresores );
            err_est = obj.Y - regresores*coef;
            est_sigma = sqrt((err_est'*err_est)/(obj.N - size(regresores,2)));
        end
    end
end