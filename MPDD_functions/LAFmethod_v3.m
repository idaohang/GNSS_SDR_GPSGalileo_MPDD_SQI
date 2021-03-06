function [N,U,w,y,ynew,D,e,powers,error_vec,Particular_ratio]=LAFmethod_v3(u,d,M,LOS,Num_epoch)

N=length(u);
%M=floor(Particular_ratio*(N-1));
Particular_ratio=M/N;

U=zeros(N-M+1,M);           % Correlation Matrix
w=zeros(M,Num_epoch);         % weights of ideal correlation
error_vec=zeros(M,Num_epoch);   % error vector for covariance calculation

powers=zeros(Num_epoch,5);  % Powers matrix

% LOS=1;                    % Index of LOS
% ynewMean=zeros(N-M+1,1);
% yMean=zeros(N-M+1,1);

y=zeros(N-M+1,Num_epoch);
ynew=zeros(N-M+1,Num_epoch);


e=zeros(N-M+1,1);


for col=1:M
 U(:,col)=u(M-col+1:1:N-col+1);
 %U(:,M-col+1)=u(M-col+1:1:N-col+1);
end 
phi=U'*U;

epoch=1;

if length(d)~=N-M+1
    D=d(M:N,epoch);
    %D=d(N:-1:M,epoch);
else
    D=d(:);
end
theta=U'*D;
w(:,epoch)=(phi)\theta; % Estimation of FIR coefficients
%%%%%
%y=filter(w(:,epoch),1,u(M:N,epoch));
y(:,epoch)=U*w(:,epoch);
%e=d(:,epoch)-y;
e(:,epoch)=D-y(:,epoch);

% Power measurement
%ynew=(y-w(1,epoch)*u(:,epoch));
ynew(:,epoch)=y(:,epoch)-w(LOS,epoch)*U(:,LOS);
%ynew=U(:,2:end)*w(2:end,epoch); % Same thing as ynew

% ynewMean=ynewMean+ynew(:,epoch);
% yMean=yMean+y(:,epoch);

    % powers= [Pu Pside Ptot Pmeasur Pe]
    %                                               u(M:N,epoch)
    powers(epoch,1)=sum(abs(w(LOS,epoch)*U(:,LOS)).^2);        % Pu
    powers(epoch,2)=sum(abs(ynew(:,epoch)).^2);                % Pside
    powers(epoch,3)=sum(abs(y(:,epoch)).^2);                   % Ptot

    powers(epoch,4)=sum(abs(D).^2);                            % Pmeasur
    powers(epoch,5)=sum(abs(e(:,epoch)).^2);                   % Pe
   
% P=U*inv(U'*U)*U'; % Projection operator (Haykin pag.498)
% emin=(eye(size(P))-P)*D;    
% result=emin'*D    
    
    error_vec(:,epoch)=w(:,epoch)-mean(w(:,epoch));%-w(1,epoch);

    % powers2(epoch)=mean(y(:,epoch).^2+(w(LOS,epoch)*U(:,LOS)).^2);

end
       