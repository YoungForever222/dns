%
%########################################################################
%#  plot of DNS structure function output file
%########################################################################
%
%
clear all;
apply_fix=0;

range=0:50;
%range = 1
%range=0:.5:2;

%fid=fopen('test32.scalars','r','l');
%fid=fopen('n128.scalars','r','b');
%fid=fopen('../src/test32.scalars','r','l');

fid=fopen('iso12_256_200.scalars','r','b'); apply_fix=1;



nscalars=0;
nscalars_e=0;
while (1) 
  [ni,count]=fread(fid,1,'float64');
  if (count~=1) break; end;
  nints=ni;
  ns=fread(fid,1,'float64');
  mu=fread(fid,1,'float64');
  alpha=fread(fid,1,'float64');
  
  [nints,ns,nscalars]
  data1=fread(fid,[nints,ns],'float64');
  data2=fread(fid,[nints,ns],'float64');

  if (nscalars==0) 
    ints=data1;
    maxs=data2;
  else
    ints=[ints,data1];
    maxs=[maxs,data2];
  end
  nscalars=nscalars+ns;

  % now read the "expensive" integrals, which are not computed every time step
  ns_e = fread(fid,1,'float64');
  time = fread(fid,1,'float64');
  data1 = fread(fid,[ns_e,1],'float64');
  data1=[time;data1];
  if (nscalars_e==0) 
    ints_e= data1;
  else
    ints_e= [ints_e,data1];
  end
  nscalars_e=nscalars_e+1;
  
end

disp(sprintf('nints=%i  total scalars read=%i',nints,nscalars))
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  through away some bad data:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (apply_fix) 
  good=[1,103:2596,2699:6073,6176:9125];
  maxs=maxs(:,good);
  ints=ints(:,good);
  nscalars=length(good);
  
  %good=[1:1082,2496:nscalars];
  good=[2496:nscalars];
  maxs=maxs(:,good);
  ints=ints(:,good);
  nscalars=length(good);
  
  s=size(ints_e);
  good=24:s(2);
  ints_e=ints_e(:,24:s(2));
  nscalars_e=length(good)
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  the scalars computed every time step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ke=ints(1,:);   % ke at time timeU
ke_diss_d=-mu*ints(2,:);
ke_diss_f=ints(3,:);        % < u,F >   F=f, except for alpha model F=f'
vor_z=ints(4,:);
hel=ints(5,:);
% ints(6,:)   ke at time timeDU
% ints(7,:)   enstrophy
% ints(8,:)   < u,div(tau)' >  (alpha model only)
% ints(9,:)   < u,f>           (alpha model only)
% ints(10,:)  < u_xx,u_xx> >   (used for E_alpha dissapation term)

maxU=maxs(1,:);
maxV=maxs(2,:);
maxW=maxs(3,:);
%  maxs(4,:)  % max used for CFL
maxvor=maxs(5,:);
timeU=maxs(6,:);
timeDU=maxs(7,:);
Ea_diss_tot=maxs(8,:);
ke_diss_tot=maxs(9,:);



disp(sprintf('max vor_z = %e',max(vor_z)));

figure(5)
clf
hold on
plot(timeU,ke)
plot(timeDU(2:nscalars),ke_diss_tot(2:nscalars),'r')
plot(timeDU,ke_diss_f+ke_diss_d,'k')
plot(timeDU,ke_diss_f,'k')
plot(timeDU,ke_diss_d,'k')
plot(timeDU,hel,'g')
title('KE: blue,    d(KE)/dt: black & red,    hel: green');
hold off


lambda=sqrt(  5*(2*ints(1,:))./ints(2,:)  );
R_l = lambda.*sqrt(2*ints(1,:))/mu;

print -depsc scalars.ps




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  the "expensive" scalars 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_e=ints_e(1,:);
ux2=zeros([3,nscalars_e]);
ux3=ux2;
ux4=ux2;
for i=1:3
   ux2(i,:)=ints_e(i+1,:);    % < u1,1 ^ 2 >
   ux3(i,:)=ints_e(i+4,:);    % < u1,1 ^ 3 >
   ux4(i,:)=ints_e(i+7,:);    % < u1,1 ^ 4 >
end
Sww=ints_e(11,:);
if (ns_e>=13) 
  for i=1:3
    u2(i,:)=ints_e(i+11,:);              % < u^2 >
  end
end


figure(6)
clf
hold on
%plot(time_e,Sww)

%plot(time_e,ux2(1,:),'k')
%plot(time_e,ux2(2,:),'b')
%plot(time_e,ux2(3,:),'g')

plot(time_e,ux3(1,:)./ux2(1,:).^(3/2),'k')
plot(time_e,ux3(2,:)./ux2(2,:).^(3/2),'b')
plot(time_e,ux3(3,:)./ux2(3,:).^(3/2),'g')

plot(time_e,ux4(1,:)./ux2(1,:).^2,'r')
plot(time_e,ux4(2,:)./ux2(2,:).^2,'b')
plot(time_e,ux4(3,:)./ux2(3,:).^2,'g')


hold off
















