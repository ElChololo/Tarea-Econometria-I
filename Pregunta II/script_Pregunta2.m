%% Pregunta I
df=setII('simce.csv','prior_sep.csv');
%% Pregunta II
[coef, err_est, r2] = df.mco_est([ones(df.obs,1) df.tabla{:,[  "prom_prioritario" "cod_rural_rbd"]} df.dummie_depe(:,2:end) df.dummie_grupo(:,2:end)])
%% Pregunta III
prioritarios = df.tabla{:,end} .* 100;
[coef, err_est, r2]=df.mco_est([ones(df.obs,1)  prioritarios df.tabla{:, "cod_rural_rbd"} df.dummie_depe(:,2:end) df.dummie_grupo(:,2:end)])

%% Pregunta IV
prioritarios_2 = prioritarios .^2;
[coef, err_est, r2 , mvarcov]=df.mco_est([ones(df.obs,1)  prioritarios prioritarios_2 df.tabla{:, "cod_rural_rbd"} df.dummie_depe(:,2:end) df.dummie_grupo(:,2:end)]);
coef, err_est, r2
%% Pregunta V
efecto_marginal = df.efc_marginal(prioritarios,coef,mvarcov);


