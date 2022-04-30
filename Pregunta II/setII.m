classdef setII
    %objeto desarrollado para Pregunta II.

    properties
        tabla
        idx
        prom_simce
        obs
        regresores
        dummie_grupo
        dummie_depe
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
            obj.dummie_depe = dummyvar(obj.tabla{:,2});
            obj.dummie_grupo = dummyvar(obj.tabla{:,3});
            obj.regresores = [ones(obj.obs,1) obj.tabla{:,[  "prom_prioritario" "cod_rural_rbd"]} obj.dummie_depe(:,2:end) obj.dummie_grupo(:,2:end)];
            
        end
        function [coef, err_est_beta, r2 ,mvarcov ] = mco_est(obj,regresores)
            mco = @(Y,X) (X'*X)\(X'*Y);
            coef = mco(obj.prom_simce ,regresores );
            err_est = obj.prom_simce - regresores*coef;
%             est_sigma = (err_est'*err_est)/(obj.obs - size(regresores,2));
%             mvarcov = est_sigma*(regresores'*regresores)^(-1);

            mvarcov = (obj.obs/ (obj.obs - size(regresores,2)))* ...
                ((regresores'*regresores)\((regresores.*err_est)'*(regresores.*err_est))) ...
                / (regresores'*regresores);
             err_est_beta= sqrt(diag(mvarcov));

            y_desv_media = obj.prom_simce - mean(obj.prom_simce);
            r2 = 1 - (err_est'*err_est)/(y_desv_media'*y_desv_media);
            
       
            
        end
        function efecto_marginal= efc_marginal(obj,prioritarios,coef,mvarcov)
            betas_obj = coef(2:3);
            efecto_marginal = betas_obj(1) + 2 * betas_obj(2)*prioritarios;
            figure(3)
            clf
            plot(prioritarios,efecto_marginal,'r');
            
            rango_valores_prioritarios=(1:101)-1;
            efecto_marginal_rango = betas_obj(1) + 2 * betas_obj(2)*rango_valores_prioritarios;
            var_efecto_marginal = mvarcov(2,2) +4*(rango_valores_prioritarios.^2).*mvarcov(3,3)+4*rango_valores_prioritarios.*mvarcov(3,2);
            int_con_inf = efecto_marginal_rango -1.96*sqrt(var_efecto_marginal);
            int_con_sup = efecto_marginal_rango +1.96*sqrt(var_efecto_marginal);
            figure(4)
            clf
             plot(rango_valores_prioritarios,efecto_marginal_rango,'r');
            hold on
            plot(rango_valores_prioritarios,int_con_inf,'g');
            hold on
            plot(rango_valores_prioritarios,int_con_sup,'g');
        end
        
        

    end
end