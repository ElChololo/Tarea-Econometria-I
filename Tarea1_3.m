clc
clear all
cd('D:\Universidad\SEMESTRE 1 MAGISTER\ECONOMETRIA I\Tareas\Tarea 1')
%% Cargar los datos y generar variables
% Generamos variables con el mismo nombre que asignan en el paper y en el excel, así
% no nos confundimos al momento de seleccionar los datos
data = xlsread('DDK2011.xlsx');
schoolid = data(:,2);
tracking = data(:,7);
totalscore = data(:,39);

%% Regresión del rendimiento académico en tracking
y = totalscore;
x = [ones(size(y,1),1),tracking];
[n,k] = size(x);
xx = x'*x;
invx = inv(xx);
beta = inv(xx)*(x'*y)
e = y - x*beta;


% Obtención de errores estándar robustos sin agrupar
rss = e'*e/(n-k);
a = n/(n-k);
u1 = x.*e;
v1 = a*inv(x'*x)*(u1'*u1)*inv(x'*x);
sbeta = sqrt(diag(v1)); %Utilizamos heterocedasticidad robusta
varbetahat = rss * inv(x'*x);
se = sqrt(rss*diag((x'*x)^(-1)));

fprintf("\n Regresión Lineal de Rendimiento Académico en Tracking");
fprintf("\n Coeficientes estimados \n");
display(beta');
fprintf("Errores estándar robustos \n");
display(se');
diary off;





%% Errores estándar agrupados por colegio (Regresión Lineal en Tracking)
[schools,~,schoolidx] = unique(schoolid);
G = size(schools,1);
c_sumas = zeros(G,k);
for (j = 1:k) 
    c_sumas(:,j) = accumarray(schoolidx,x(:,j).*e);
end
matcovar = c_sumas'*c_sumas;
a = G/(G-1)*(n-1)/(n-k);
%Obtenemos la matriz de covarianzas 
V_c = a*invx*matcovar*invx;
sec = sqrt(diag(V_c));

betanames=['beta0';'beta1']
varnombres=['cons';'trac'];

tstudent1 = beta./sbeta
pvalue1 = 2*(1-tcdf(abs(tstudent1),length(y)-k));
tstudent2 = beta./sec
pvalue2 = 2*(1-tcdf(abs(tstudent2),length(y)-k));

t = table(betanames,varnombres,beta,sbeta,pvalue1,sec,pvalue2)
filename='tabla31.xlsx';
writetable(t,filename,'Sheet',1,'Range','D1')


%% Errores estándar robustos agrupados por colegio (Regresión Lineal en Tracking)
%%NO REVISAR ESTO. ES UN ACTO DE HONESTIDAD.
%[schools,~,schoolidx] = unique(schoolid);

%Obtenemos u1 (sum_g (eg'*xg)'*(eg'*xg)):
%G = size(schools,1);
%u1_sums = zeros(G,k);
%eg = zeros(G,k);
%ng = accumarray(schoolidx,1);
%miau = zeros(n,2);
%ng2 = zeros(n,1);
%for i=1:n
%ng2(i) = ng(schoolidx(i));
%end    
%ng = ng2;

%acng = accumarray(schoolidx,1);

%for i=1:G-1
 %   acng(i+1) = acng(i) + acng(i+1);
%end
%for i=1:n
 %   ng2(i) = acng(schoolidx(i));
%end
%% 
% Intentamos resolverlo con el álgebra matricial del libro, pero no daba
% porque en la fórmula se indica que es                                      
%~e = (I_{ng} - Xg(X'X)^{-1}Xg')^{-1}*e_g 
% Sin embargo, lo anterior no considera que Xg tiene dimension (ng)x(j), pero
% (X'X)^{-1} tiene dimensión (n)x(n). Por lo tanto, sólo podría hacerse si
% trabajáramos con (X_g'X_g)^{-1}. Sin embargo, sabemos que para varias 
% observaciones de X de un mismo cluster (Xg) son SÓLO UNOS. Por lo tanto,
% es directo que las matrices serían singulares (determinante = 0) e
% invertibles si aplicáramos esa fórmula. 

%Dado lo anterior, no se ocupa esto, sino que como se verá en la siguiente
%sección, haremos uso de la extensión de Arellano (1980) para estimar
%errores estándares robustos para datos de panel, pero en este caso
%modificaremos lo obtenido para incluir clusters y hacer la estimación de
%errores estándares robustos clustereados.

%Esto NO SE REVISA%
%for j = 1:k
 %   for i = 1:n
  %      for k=1:G
   % xj = x(acng(k):acng(k+1),j);
    %xxj = xj'*xj;
    %invxj = inv(xxj);
    %ej = e(acng(k):acng(k+1),j);
   % miau = inv(eye(ng2(i))- xj*invxj*xj')*ej
    
%u1_sums(:,j) = accumarray(schoolidx,xj'*(inv(eye(ng2(i))- xj*invxj*xj')*ej)*(inv(eye(ng2(i))- xj*invxj*xj')*ej)'*xj);
 %   end
%end  
%end


%% Pregunta 2. Regresión del rendimiento en tracking, edad, género, asignación y percentil.
edad = data(:,10);
schoolid = data(:,2);
tracking = data(:,7);
totalscore = data(:,39);
mujer=data(:,9);
asignacion=data(:,11);
percentil = data(:,23);
percentilreal = data(:,24);
y = totalscore;

x = [y,schoolid,ones(size(y,1),1),tracking,edad,mujer,asignacion,percentil];
x = rmmissing(x); %Decidimos deshacernos de las filas con NA para la estimación.
y = x(:,1);
schoolid = x(:,2);
x(:,1) = [];
x(:,2) = [];
[n,k] = size(x);
xx = x'*x;
invx = inv(xx);
beta = xx\(x'*y)
e = y - x*beta;
% Obtención de errores estándar robustos sin agrupar
rss = e'*e/(n-k);
a = n/(n-k);
u1 = x.*e;
v1 = a*inv(x'*x)*(u1'*u1)*inv(x'*x);
sbeta = sqrt(diag(v1)); %Utilizamos heterocedasticidad robusta
varbetahat = rss * inv(x'*x);
se = sqrt(rss*diag((x'*x)^(-1)));

% Calculamos errores estándar clustereados
[schools,~,schoolidx] = unique(schoolid);
G = size(schools,1);
c_sumas = zeros(G,k);
for j = 1:k 
    for i = 1:n
    c_sumas(:,j) = accumarray(schoolidx,x(:,j).*e);
    end
end
matcovar = c_sumas'*c_sumas;
a = G/(G-1)*(n-1)/(n-k);
V_c = a*invx*matcovar*invx;
sec = sqrt(diag(V_c));

tstudent1 = beta./sbeta
pvalue1 = 2*(1-tcdf(abs(tstudent1),length(y)-k));
tstudent2 = beta./sec
pvalue2 = 2*(1-tcdf(abs(tstudent2),length(y)-k));

betanames=['beta0';'beta1';'beta2';'beta3';'beta4';'beta5']
varnombres=['cons';'trac';'edad';'girl';'assg';'pctl']
t = table(betanames,varnombres,beta,sbeta,pvalue1,sec,pvalue2)
filename='tabla32.xlsx';
writetable(t,filename,'Sheet',1,'Range','D1')


%% Pregunta 3

% Aplicación de Efectos Fijos
%Obtenemos u1 (sum_g (eg'*xg)'*(eg'*xg)):
G = size(schools,1);
u1_sums = zeros(G,k);
eg = zeros(G,k);
ng = accumarray(schoolidx,1);
miau = zeros(n,2);
ng2 = zeros(n,1);
for i=1:n
ng2(i) = ng(schoolidx(i));
end    
ng = ng2;
acng = accumarray(schoolidx,1);
%Generamos dummies por cada cluster 
dummy = dummyvar(schoolidx);



edad = data(:,10);
schoolid = data(:,2);
tracking = data(:,7);
totalscore = data(:,39);
mujer=data(:,9);
asignacion=data(:,11);
percentil = data(:,23);
percentilreal = data(:,24);
y = totalscore;

x = [y,schoolid,ones(size(y,1),1),tracking,edad,mujer,asignacion,percentil];
x = rmmissing(x); %Decidimos deshacernos de las filas con NA para la estimación.
y = x(:,1);
schoolid = x(:,2);
x(:,1) = [];
x(:,2) = [];
x = [x,dummy];
[n,k] = size(x);
xx = x'*x;
invx = inv(xx);
beta = xx\(x'*y)
e = y - x*beta;

% Calculamos errores estándar robustos
rss = e'*e/(n-k);
a = n/(n-k);
u1 = x.*e;
v1 = a*inv(x'*x)*(u1'*u1)*inv(x'*x);
sbeta = sqrt(diag(v1)); %Utilizamos heterocedasticidad robusta
varbetahat = rss * inv(x'*x);
se = sqrt(rss*diag((x'*x)^(-1)));

fprintf("\n Regresión Múltiple de Rendimiento Académico en Tracking");
fprintf("\n Coeficientes estimados \n");
display(beta');
fprintf("Errores estándar robustos \n");
display(sbeta');
diary off;

%Algunas son cercanas a singulares y no puede calcularse.



betanames=['beta0';'beta1';'beta2';'beta3';'beta4';'beta5'];
varnombres=['cons';'trac';'edad';'girl';'assg';'pctl'];

tstudent1 = beta./sbeta
pvalue1 = 2*(1-tcdf(abs(tstudent1),length(y)-k));

betas = beta(1:6,:);
sbetas = sbeta(1:6,1);
pvalues = pvalue1(1:6,1);
t = table(betanames,varnombres,betas,sbetas,pvalues)
filename='tabla33.xlsx';
writetable(t,filename,'Sheet',1,'Range','D1')





%% Pregunta 4

edad = data(:,10);
schoolid = data(:,2);
tracking = data(:,7);
totalscore = data(:,39);
mujer=data(:,9);
asignacion=data(:,11);
percentil = data(:,23);
percentilreal = data(:,24);
y = totalscore;

x = [y,schoolid,ones(size(y,1),1),tracking,mujer,tracking.*mujer,edad,asignacion,percentil];
x = rmmissing(x); %Decidimos deshacernos de las filas con NA para la estimación.
y = x(:,1);
schoolid = x(:,2);
x(:,1) = [];
x(:,2) = [];
[n,k] = size(x);

xx = x'*x 
    
invx = inv(xx);
beta = xx\(x'*y)
e = y - x*beta;

% Calculamos errores estándar robustos
rss = e'*e/(n-k);
a = n/(n-k);
u1 = x.*e;
v1 = a*inv(x'*x)*(u1'*u1)*inv(x'*x);
sbeta = sqrt(diag(v1)); %Utilizamos heterocedasticidad robusta
varbetahat = rss * inv(x'*x);
se = sqrt(rss*diag((x'*x)^(-1)));

fprintf("\n Regresión Múltiple de Rendimiento Académico en Tracking");
fprintf("\n Coeficientes estimados \n");
display(beta');
fprintf("Errores estándar robustos \n");
display(sbeta');
diary off;


% Calculamos errores estándar clustereados
[schools,~,schoolidx] = unique(schoolid);
G = size(schools,1);
c_sumas = zeros(G,k);
for j = 1:k 
    for i = 1:n
    c_sumas(:,j) = accumarray(schoolidx,x(:,j).*e);
    end
end
matcovar = c_sumas'*c_sumas;
a = G/(G-1)*(n-1)/(n-k);
V_c = a*invx*matcovar*invx;
sec = sqrt(diag(V_c));

tstudent1 = beta./sbeta
pvalue1 = 2*(1-tcdf(abs(tstudent1),length(y)-k));
tstudent2 = beta./sec
pvalue2 = 2*(1-tcdf(abs(tstudent2),length(y)-k));


betanames=['beta0';'beta1';'beta2';'beta3';'beta4';'beta5';'beta6'];
varnombres=['cons';'trac';'edad';'girl';'tr_g';'assg';'pctl'];

t = table(betanames,varnombres,beta,sbeta,pvalue1,sec,pvalue2)
filename='tabla34.xlsx';
writetable(t,filename,'Sheet',1,'Range','D1')

