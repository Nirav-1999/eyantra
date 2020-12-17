global A = csvread('csv_matter.csv');  #do not change this line

################################################
#######Declare your global variables here#######
################################################
global X;
X=zeros(size(A,1),3);
global Y;
Y=zeros(size(A,1),3);
Y(1,:)=[0 0 0];
global P;
P=zeros(size(A,1),3);
global Q;
Q=zeros(size(A,1),3);
Q(1,:)=[0 0 0];
global angle;
angle=zeros(size(A,1),1);
global angx;
angx=zeros(size(A,1),1);
global angacc
angacc=zeros(size(A,1),1);
global angy;
angy=zeros(size(A,1),1);
global roll;
roll=zeros(size(A,1),1);


function read_accel(axl,axh,ayl,ayh,azl,azh,n)  
  global X;
  global angacc;
  
  #################################################
  ####### Write a code here to combine the ########
  #### HIGH and LOW values from ACCELEROMETER #####
  #################################################
  axl=dec2bin(axl,8);
  axh=dec2bin(axh,8);
  ayl=dec2bin(ayl,8);
  ayh=dec2bin(ayh,8);
  azl=dec2bin(azl,8);
  azh=dec2bin(azh,8);
  ax=strcat(axh,axl);
  ay=strcat(ayh,ayl);
  az=strcat(azh,azl);
  ax=bin2dec(ax);
  ay=bin2dec(ay);
  az=bin2dec(az);
  if ax>32767
    ax = ax - 65536;
   endif
   if ay>32767
    ay = ay - 65536;
   endif
   if az>32767
    az = az - 65536;
   endif
   ax = ax/16384;
   ay = ay/16384;
   az = az/16384;

  X(n,1)=ax;
  X(n,2)=ay;
  X(n,3)=az;
  
  angacc(n,1) = rad2deg(atan2(ax,sqrt(az*az+ay*ay)));


  ####################################################
  # Call function lowpassfilter(ax,ay,az,f_cut) here #
  ####################################################
  lowpassfilter(ax,ay,az,5,n);

endfunction

function read_gyro(gxl,gxh,gyl,gyh,gzl,gzh,n)
  global P;
  global angx;
  global angy;
  
  #################################################
  ####### Write a code here to combine the ########
  ###### HIGH and LOW values from GYROSCOPE #######
  #################################################
  gxl=dec2bin(gxl,8);
  gxh=dec2bin(gxh,8);
  gyl=dec2bin(gyl,8);
  gyh=dec2bin(gyh,8);
  gzl=dec2bin(gzl,8);
  gzh=dec2bin(gzh,8);
  gx=strcat(gxh,gxl);
  gy=strcat(gyh,gyl);
  gz=strcat(gzh,gzl);
  gx=bin2dec(gx);
  gy=bin2dec(gy);
  gz=bin2dec(gz);
  
  if gx>32767
    gx = gx - 65536;
   endif
   if gy>32767
    gy = gy - 65536;
   endif
   if gz>32767
    gz = gz - 65536;
   endif
   gx = gx/131;
   gy = gy/131;
   gz = gz/131;

  P(n,1)=gx;
  P(n,2)=gy;
  P(n,3)=gz;
  if n!= 1
    angx(n,1) = angx(n-1,1) + P(n,1)*0.01;
    angy(n,1) = angy(n-1,1) + P(n,2)*0.01;

  endif
  #####################################################
  # Call function highpassfilter(ax,ay,az,f_cut) here #
  #####################################################;
  highpassfilter(gx,gy,gz,5,n);

endfunction



function lowpassfilter(ax,ay,az,f_cut,n)
  dT = 0.01;  #time in seconds
  Tau= 0.0318;
  alpha = Tau/(Tau+dT);    #do not change this line
  
  ################################################
  ##############Write your code here##############
  ################################################
global X;
global Y;
global angacc;
  Y(1) = angacc(1);
  if n!=1
    Y(n,:) =(1-alpha)*angacc(n,:) + alpha*Y(n-1,:);
  
  endif
  
endfunction



function highpassfilter(gx,gy,gz,f_cut,n)
  dT = 0.01;  #time in seconds
  Tau=0.0318 ;
  alpha = Tau/(Tau+dT);                #do not change this line
  
  ################################################
  ##############Write your code here##############
  ################################################
  global P;
  global Q;
  global angx;
  global angy;
  
  if n!=1 
    Q(n,:) =(1-alpha)*Q(n-1,:) + (1-alpha)*(angy(n,:)-angy(n-1,:)) ;
    
  endif
    
  
endfunction

function comp_filter_pitch(ax,ay,az,gx,gy,gz,n)

  ##############################################
  ####### Write a code here to calculate  ######
  ####### PITCH using complementry filter ######
  ##############################################
  global angle;
  global angacc;
  global angx;
  global Q;
  global Y;
  alpha=0.3;
  dt=0.01;
  #roll = atan2(ay, az)
  #pitch = atan2(-ax, sqrt(ay*ay + az*az))

  #Pitch = asin(-ax);
 # Roll = asin( ay / cos(Pitch)  );
 if n!=1
     #angle(n,1)=(1-alpha)*(angle(n,1)+(gx)*dt) + (alpha)*rad2deg(atan2(ax,sqrt(az*az+ay*ay)));
    #angle(n,1)=(1-alpha)*(rad2deg(atan2(ay,az))+(gx)*dt) + (alpha)*rad2deg(atan2(ay,az));

  
        angle(n,1)=(1-alpha)*Q(n,1) + (alpha)*angacc(n,1);

   #angle(n,1)=(1-alpha)*(angle(n-1,1)+(gx)*dt) + (alpha)*(Y(n,2)-Y(n-1,2)+Y(n,3)-Y(n-1,3));
  #angle(n,1)=(1-alpha)*(Q(n,1)+(gx)*dt) + (alpha)*(ay-az);
  #angle(n,1)=(1-alpha)*(angle(n-1,1)+(gx)*dt) + (alpha)*rad2deg(atan2(ax,sqrt(az*az+ay*ay)));
  endif

endfunction 

function comp_filter_roll(ax,ay,az,gx,gy,gz,n)

  ##############################################
  ####### Write a code here to calculate #######
  ####### ROLL using complementry filter #######
  ##############################################
  global angle;
  global angacc;
  global angx;
  global Q;
  global Y;
    global angy;
    global roll;

  alpha=0.3;
  dt=0.01;
  #roll = atan2(ay, az)
  #pitch = atan2(-ax, sqrt(ay*ay + az*az))

  #Pitch = asin(-ax);
 # Roll = asin( ay / cos(Pitch)  );
 if n!=1
    roll(n,1)=(1-alpha)*Q(n,2) + (alpha)*angacc(n,1);
  endif

endfunction 

function execute_code
  global A;
  global B;
  global X;
  global Y;
  global P;
  global Q;
  

  for n = 1:rows(A)                    #do not change this line
    
    ###############################################
    ####### Write a code here to calculate  #######
    ####### PITCH using complementry filter #######
    ###############################################
 
    read_accel(A(n,1),A(n,2),A(n,3),A(n,4),A(n,5),A(n,6),n);
    read_gyro(A(n,7),A(n,8),A(n,9),A(n,10),A(n,11),A(n,12),n);
    comp_filter_pitch(Y(n,1),Y(n,2),Y(n,3),Q(n,1),Q(n,2),Q(n,3),n);
    comp_filter_roll(Y(n,1),Y(n,2),Y(n,3),Q(n,1),Q(n,2),Q(n,3),n);

    
  endfor
  csvwrite('output_data.csv',B);        #do not change this line
endfunction


execute_code                           #do not change this line
