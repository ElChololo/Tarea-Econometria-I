%% Pregunta I
df=setII('simce.csv','prior_sep.csv');
[est_descript_g ,est_descript_x_rural ,est_descript_x_grup, est_descript_x_depe ] = df.est_descript();
%% Pregunta II
[coef, err_est, r2] = df.mco_est([ones(df.obs,1) df.tabla{:,"prom_prioritario" } df.dummie_depe(:,2:end) df.dummie_grupo(:,2:end) df.dummie_rural(:,2) ])
%% Pregunta III
prioritarios = df.tabla{:,end} .* 100;
[coef, err_est, r2]=df.mco_est([ones(df.obs,1)  prioritarios  df.dummie_depe(:,2:end) df.dummie_grupo(:,2:end)  df.dummie_rural(:,2) ])

%% Pregunta IV
prioritarios_2 = prioritarios .^2;
[coef, err_est, r2 , mvarcov]=df.mco_est([ones(df.obs,1)  prioritarios prioritarios_2  df.dummie_depe(:,2:end) df.dummie_grupo(:,2:end)  df.dummie_rural(:,2)] )

%% Pregunta V
efecto_marginal = df.efc_marginal(prioritarios,coef,mvarcov);


