%% Pregunta 1
p1 = PreguntaI([1 2 4 6], [0 5 7], 1e3 , 1 ,1,1);
%% Pregunta 2
[p2, ~ , var_betas] = p1.PreguntaI_est([ones(p1.N,1) p1.X1 p1.X2 p1.X3])
%% Pregunta 3
[p3, ~ , var_betas] = p1.PreguntaI_est([ones(p1.N,1) p1.X1 p1.X2])
%% Pregunta 4
[p4, ~ , var_betas] = p1.PreguntaI_est([ones(p1.N,1) p1.X1])
%% Pregunta 5
p5_0 = PreguntaI([1 2 4 6], [0 0 0], 1e3 , 1 ,1,1);
[p5_1, ~ , var_betas] = p5_0.PreguntaI_est([ones(p1.N,1) p1.X1 p1.X2 p1.X3]);
[p5_2, ~ , var_betas] = p5_0.PreguntaI_est([ones(p1.N,1) p1.X1 p1.X2 ]);
[p5_3, ~ , var_betas] = p5_0.PreguntaI_est([ones(p1.N,1) p1.X1]);

%% Pregunta 6
p6 =PreguntaI([1 2 4 6], [0 0 0], 1e3 , 1 ,1,1);
[p6_1, ~ , var_betas] = p6.PreguntaI_est([ones(p1.N,1) p1.X1])
[test_t_est, test_f]=p1.tests([ones(p1.N ,1) p1.X1 p1.X2 p1.X3]);
test_t_est_graf = zeros(2,500);
test_f_est_graf = zeros(1,500);

for ii =1:500
    s = PreguntaI([1 2 4 6], [0 0 0], 1000, ii/100 , 1,0);
    [test_t_est, test_f] = s.tests([ones(p6.N,1) s.X1 s.X2 s.X3]);
    test_t_est_graf (1,ii) = test_t_est(1);
    test_t_est_graf(2,ii)= test_t_est(2);
    test_f_est_graf(ii)=test_f;
end

figure(1)
clf

plot( (1:500)/100 ,test_t_est_graf(1,:),'g',(1:500)/100 ,test_t_est_graf(2,:),'b')
title('Estadístico t ante cambios en \sigma_v')
xlabel('\sigma_v')
ylabel('estadístico t-student')
legend({'test-t \beta_1 = 0', 'test-t \beta_2 = 0'}, 'location','best')

%% Pregunta 7
test_f;
figure(2)
clf

plot( (1:500)/100 ,test_f_est_graf,'k');
title('Estadístico F ante cambios en \sigma_v')
xlabel('\sigma_v');
ylabel('estadístico F');
legend('test-F \beta_1 = 0 y \beta_2 = 0');