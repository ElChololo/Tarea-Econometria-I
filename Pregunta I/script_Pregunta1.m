s = PreguntaI([1 2 4 6], [0 5 7], 1000, 1 , 1);
[test_t_est] = s.testt([s.X1 s.X2 s.X3]);
[test_t_est_graf] = ones(2,50);
for ii =1:50
    s = PreguntaI([1 2 4 6], [0 5 7], 1000, ii , 1);
    [test_t_est] = s.testt([s.X1 s.X2 s.X3]);
    test_t_est_graf (1,ii) = test_t_est(1);
    test_t_est_graf(2,ii)= test_t_est(2);
end