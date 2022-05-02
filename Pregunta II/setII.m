classdef setII
    %objeto desarrollado para Pregunta II.

    properties
        tabla
        idx
        prom_simce
        obs
        dummie_grupo
        dummie_depe
        dummie_rural
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
            obj.dummie_rural = dummyvar(obj.tabla{:,4});
            
        end
        function [est_descript_g ,est_descript_x_rural ,est_descript_x_grup, est_descript_x_depe ] = est_descript(obj)
            % Hacer estadística descriptiva prom_simce según 4 criterios, datos genererales, datos por ruralidad, GSE y Dependencia 
            col_prom_simce = table(obj.prom_simce, 'VariableNames',{'Prom_Simce'});
            datos = [obj.tabla col_prom_simce];
%             est = @(row_constraint) [ length(datos{row_constraint,end}) mean(datos{row_constraint,end}) std(datos{row_constraint,end}) ... 
%                 min(datos{row_constraint,end}) max(datos{row_constraint,end})];
%           hacer llamados a la función, pero mejorará la lectura del código? = est(ones(obj.obs,1))
            est_descript_g = [ length(datos{:,end}) mean(datos{:,end}) std(datos{:,end}) min(datos{:,end}) max(datos{:,end})];
            row_urb = datos{:,"cod_rural_rbd"} ==1;
            row_rural = datos{:,"cod_rural_rbd"} ==2;
            
            est_descript_x_rural = [ length(datos{row_urb,end}) mean(datos{row_urb,end}) std(datos{row_urb,end}) min(datos{row_urb,end}) max(datos{row_urb,end}) ; ...
                length(datos{row_rural,end}) mean(datos{row_rural,end}) std(datos{row_rural,end}) min(datos{row_rural,end}) max(datos{row_rural,end})];
            
            row_bajo = datos{:,"cod_grupo"} ==1;
            row_med_bajo = datos{:,"cod_grupo"} ==2;
            row_med = datos{:,"cod_grupo"} ==3;
            row_med_alto = datos{:,"cod_grupo"} ==4;
            row_alto = datos{:,"cod_grupo"} ==5;
            
            est_descript_x_grup = [ length(datos{row_bajo,end}) mean(datos{row_bajo,end}) std(datos{row_bajo,end}) min(datos{row_bajo,end}) max(datos{row_bajo,end}) ; ...
                 length(datos{row_med_bajo,end}) mean(datos{row_med_bajo,end}) std(datos{row_med_bajo,end}) min(datos{row_med_bajo,end}) max(datos{row_med_bajo,end}) ; ...
                 length(datos{row_med,end}) mean(datos{row_med,end}) std(datos{row_med,end}) min(datos{row_med,end}) max(datos{row_med,end}) ; ...
                 length(datos{row_med_alto,end}) mean(datos{row_med_alto,end}) std(datos{row_med_alto,end}) min(datos{row_med_alto,end}) max(datos{row_med_alto,end}) ; ...
                 length(datos{row_alto,end}) mean(datos{row_alto,end}) std(datos{row_alto,end}) min(datos{row_alto,end}) max(datos{row_alto,end})];
            
            row_muni = datos{:,"cod_depe2"} ==1;
            row_part_subv = datos{:,"cod_depe2"} ==2;
            row_part_pag = datos{:,"cod_depe2"} ==3;
            
            est_descript_x_depe = [ length(datos{row_muni,end}) mean(datos{row_muni,end}) std(datos{row_muni,end}) min(datos{row_muni,end}) max(datos{row_muni,end}) ; ...
                length(datos{row_part_subv,end}) mean(datos{row_part_subv,end}) std(datos{row_part_subv,end}) min(datos{row_part_subv,end}) max(datos{row_part_subv,end}) ; ...
                length(datos{row_part_pag,end}) mean(datos{row_part_pag,end}) std(datos{row_part_pag,end}) min(datos{row_part_pag,end}) max(datos{row_part_pag,end})];
            
        end

        function [coef, err_est_beta, r2 ,mvarcov ] = mco_est(obj,regresores)
        %Método enfocado en la estimación de MCO obteniendo los errores estándar de los coeficientes, R^2 y matriz de varianza y covarianza, insumo necesario para ejecutar 
        %La pregunta 7.
            mco = @(Y,X) (X'*X)\(X'*Y);
            coef = mco(obj.prom_simce ,regresores );
            err_est = obj.prom_simce - regresores*coef;

            %Se decide utilizar estimacion robusta a heterocedasticidad
            %pero se deja planteada (comentada) la inferenceia utilizando
            %homocedasticidad

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
        %Método diseñado para obtener y gráficar los efectos marginales requeridos
            betas_obj = coef(2:3);
            efecto_marginal = betas_obj(1) + 2 * betas_obj(2)*prioritarios;
            figure(3)
            clf
            plot(prioritarios,efecto_marginal,'r');
            title('Efecto Marginal de variable prioritarios sobre Puntaje Simce')
            xlabel('prioritarios');
            ylabel('Efecto sobre el puntaje Simce');
            legend('Efecto variable prioritarios sobre puntaje Simce');
            saveas(gcf,'Ef_marginal.jpg')
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
            title({'Efecto Marginal de variable prioritarios sobre Puntaje Simce', 'y su intervalo de confianza al 95% de significancia'})
            xlabel('prioritarios');
            ylabel('Efecto sobre el puntaje Simce');
            legend('Efecto variable prioritarios sobre puntaje Simce','Intervalo de confianza');
            saveas(gcf,'Ef_marginal_int_conf.jpg')
        end
        
        

    end
end
