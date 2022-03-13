%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TITLE: Digital TV Lab Source Code
% EDITORS: The Buhda - Budha
% Version: 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
clc;
clear all;
close all;

%INDICES
time=0;                 %actual time slots --> index slot
MAX_time=10000;         %max. num. of slots considered
max_VIDEO_Packets=1000; %max. num. of flow packets (VIDEO) considered (Maximum - Priority)

%GLOBAL PARAMETERS

%Packet Priorities
% three types of packets where concidered in accordance to DiffServe
% standards
MAX_PR_PERC = 0.1;   % Priority 3

MED_PR_PERC = 0.2;   % Priority 2

MIN_PR_PERC = 0.7;   % Priority 1

%Buffer Properties
% current buffer counters
LB_CS=0;
B1_CS=0;
B2_CS=0;
PB_CS=0;
% buffer sizes
BUFFER_1_size = 10000;
BUFFER_2_size = 10000;
PLAYBACK_size = 200;
% buffer rates
LB_Rate=1/10;      %packets/slot
B1_Rate=1/2;        %packets/slot
B2_Rate=1/2;        %packets/slot
PB_Rate=1/5;        %packets/slot
% operational flags
pop_LB=0;
pop_B1=0;
pop_B2=0;
pop_PB=0;
% the percentage above which the playout buffers starts the streaming
PLAYOUT_PERC=0.7;

%Links Quality (percentage of packet drop)
LINK_S_R1 = 0;    %Packet Lost Probability
LINK_R1_R2 = 0;    %Packet Lost Probability
LINK_R2_D = 0;     %Packet Lost Probability

% External Buffer Traffic
INC1=1/10;      %packets/slot
INC2=1/10;      %packets/slot

% MAX delay of the next generated video packet
SOURCE_DELAY=25;

% Video packets ID counter
VP_ID= 0; 

%GENERAL PURPOSE STRUCTURES

% system buffer implementation
for i=1:2
    %LEAKY BUCKET
    for j=1:max_VIDEO_Packets
        LEAKY_BUCKET(i,j)=0;
    end

    %BUFFER_1
    for j=1:BUFFER_1_size
        BUFFER_1(i,j)=0;
    end

    %BUFFER_2
    for j=1:BUFFER_2_size
        BUFFER_2(i,j)=0;
    end

    %PLAYBACK
    for j=1:PLAYBACK_size
        PLAYBACK(i,j)=0;
    end
end

%-----------------------------------------------
% in this section intialization of the structures to be used for
% measurements

%MEASUREMENTS

number_of_packets_out_of_generator=0; 
number_of_packets_out_of_leaky_bucket=0;
number_of_packets_before_playback=0;
number_of_packets_after_playback=0;

%VIDEO PACKETS ARRIVAL TIMES - BEFORE LEAKY BUCKET(Arrival_B_LB)
Arrival_B_LB=[];
Arrival_B_LB_VS_VP_ID=[];
VP_ID_holder=[];

%VIDEO PACKETS ARRIVAL TIMES - AFTER LEAKY BUCKET  (Arrival_A_LB)
Arrival_A_LB=[];
Arrival_A_LB_VS_LB_ID=[];
LB_ID_holder=[];

%VIDEO PACKETS ARRIVAL TIMES - BEFORE PLAYBACK (Arrival_B_PB)
Arrival_B_PB=[];
Arrival_B_PB_VS_link_3_ID=[];
Before_PB_ID_holder=[];

%VIDEO PACKETS ARRIVAL TIMES - AFTER PLAYBACK  (Arrival_A_PB)
Arrival_A_PB=[];
Arrival_A_PB_VS_PB_ID=[];
After_PB_ID_holder=[];
%--------------------------------------------------------------------------

%flag indicating that a new video packet should be produced in the current
%time slot
delay_video=1;

%Initialization of the Random Number Generator
rand('state',0);

%flag indicating if the playout buffer operates above the designated
%threshold
Playout_buffer_flag=0;

%MAIN SYSTEM OPERATION
while (time<MAX_time)

    time=time+1;

    %VIDEO SOURCE PACKET GENERATOR-----------------------------------------
    NEW_PACKET=0;
    if (delay_video==0)
        delay_video=round(rand()*SOURCE_DELAY); %SCHEDULE THE ARRIVAL OF THE NEXT PACKET PRODUCED BY THE VIDEO SERVER
        delay_video=delay_video+1;
    end
    delay_video=delay_video-1;
    if (delay_video==0)
        VP_ID=VP_ID+1;
        VP_PR=3;
        NEW_PACKET=1;
    end
    %END of VIDEO SOURCE PACKET GENERATOR---------------------------------

    %------------MEASUREMENT----------------------------------------------
    % ID of Packet vs Time of Arival
    if (NEW_PACKET==1)
        % account the new packet
        Arrival_B_LB=[Arrival_B_LB;[time]];
        VP_ID_holder=[VP_ID_holder;[VP_ID]];
        Arrival_B_LB_VS_VP_ID=[Arrival_B_LB_VS_VP_ID;[VP_ID,time]];
        number_of_packets_out_of_generator=number_of_packets_out_of_generator+1; %VP_ID
    end

    %LEAKY_BUCKET----------------------------------------------------------

    %INPUT PROCCESS
    if (NEW_PACKET==1)
        [push,LEAKY_BUCKET,LB_CS]=pushBuffer(LEAKY_BUCKET,LB_CS,max_VIDEO_Packets,VP_ID,VP_PR);
    end

    %OUTPUT PROCESS

    if (mod(time,(1/LB_Rate))==0)
        [pop_LB,LEAKY_BUCKET,LB_CS,LB_ID,LB_PR]=popBuffer(LEAKY_BUCKET,LB_CS,max_VIDEO_Packets);
    end

    LEAKY_BUCKET;
    %END of LEAKY_BUCKET--------------------------------------------------

    %------------MEASUREMENT----------------------------------------------
    % ID of Packet vs Time of Arival
    if (pop_LB==1)
        % account the new packet 
        Arrival_A_LB=[Arrival_A_LB;[time]];
        LB_ID_holder=[LB_ID_holder;[LB_ID]];
        Arrival_A_LB_VS_LB_ID=[Arrival_A_LB_VS_LB_ID;[LB_ID,time]]; 
        number_of_packets_out_of_leaky_bucket=number_of_packets_out_of_leaky_bucket+1;
    end


    %LINK Soource to Router_1----------------------------------------------

    link_1=rand();
    if (link_1<LINK_S_R1)&&(pop_LB==1)  %The packet is lost
        link_1_Trans=0;
    elseif(pop_LB==0)
        link_1_Trans=0;
    else
        link_1_ID=LB_ID;
        link_1_PR=LB_PR;
        link_1_Trans=1;
    end
    pop_LB=0; %Packet has been tranfered in the link
    %END of LINK Soource to Router_1--------------------------------------



    %Router_1----------------------------------------------------------FIF0

    %INPUT PROCCESS
    % FROM LINK 1
    if (link_1_Trans==1)
        [push,BUFFER_1,B1_CS]=pushBuffer(BUFFER_1,B1_CS,BUFFER_1_size,link_1_ID,link_1_PR);
    end
    % EXTERNAL TRAFFIC
    if (mod(time,(1/INC1))==0)
        [Generator, packet_ID,packet_PR]=packet_Generator(MAX_PR_PERC,MED_PR_PERC,MIN_PR_PERC);
        [push,BUFFER_1,B1_CS]=pushBuffer(BUFFER_1,B1_CS,BUFFER_1_size,packet_ID,packet_PR);
    end
    link_1_Trans=0; %The packet has been received from the link at the router

    %OUTPUT PROCESS
    if (mod(time,(1/B1_Rate))==0)
        [pop_B1,BUFFER_1,B1_CS,B1_ID,B1_PR]=popBuffer(BUFFER_1,B1_CS,BUFFER_1_size);
    end
    BUFFER_1;
    %END of Router_1---------------------------------------------------FIF0



    %LINK Router_1 to Router_2----------------------------------------------

    link_2=rand();
    if (link_2<LINK_R1_R2)&&(pop_B1==1)  %The packet is lost
        link_2_Trans=0;
    elseif(pop_B1==0)
        link_2_Trans=0;
    else
        if (B1_ID~=-1)
            link_2_ID=B1_ID;
            link_2_PR=B1_PR;
            link_2_Trans=1;
        else
            link_2_Trans=0;
        end
    end
    pop_B1=0; %Packet has been tranfered in the link
    %END of LINK Router_1 to Router_2--------------------------------------


    %Router_2----------------------------------------------------------FIF0

    %INPUT PROCCESS
    % FROM LINK 2
    if (link_2_Trans==1)
        [push,BUFFER_2,B2_CS]=pushBuffer(BUFFER_2,B2_CS,BUFFER_2_size,link_2_ID,link_2_PR);
    end
    % EXTERNAL TRAFFIC
    if (mod(time,(1/INC2))==0)
        [Generator, packet_ID,packet_PR]=packet_Generator(MAX_PR_PERC,MED_PR_PERC,MIN_PR_PERC);
        packet_ID=packet_ID-1; %In order to check external trafic origin
        [push,BUFFER_2,B2_CS]=pushBuffer(BUFFER_2,B2_CS,BUFFER_2_size,packet_ID,packet_PR);
    end
    
    link_2_Trans=0; %The packet has been received from the link at the router

    %OUTPUT PROCESS
    if (mod(time,(1/B2_Rate))==0)
        [pop_B2,BUFFER_2,B2_CS,B2_ID,B2_PR]=popBuffer(BUFFER_2,B2_CS,BUFFER_2_size);
    end

    BUFFER_2;
    %END of Router_2---------------------------------------------------FIF0

    %LINK Router_1 to Destination------------------------------------------

    link_3=rand();
    if (link_3<LINK_R2_D)&&(pop_B2==1)  %The packet is lost
        link_3_Trans=0;
    elseif(pop_B2==0)
        link_3_Trans=0;
    else
        if (B2_ID~=-2)
            link_3_ID=B2_ID;
            link_3_PR=B2_PR;
            link_3_Trans=1;
        else
            link_3_Trans=0;
        end
    end
    pop_B2=0; %Packet has been tranfered in the link

    %END of LINK Router_1 to Destination----------------------------------


    %------------MEASUREMENT----------------------------------------------
    % ID of Packet vs Time of Arival
    if (link_3_Trans==1)
        % account for the new packet
        Arrival_B_PB_VS_link_3_ID=[Arrival_B_PB_VS_link_3_ID;[link_3_ID,time]];
        Arrival_B_PB=[Arrival_B_PB;[time]];
        Before_PB_ID_holder=[Before_PB_ID_holder;[link_3_ID]];
        number_of_packets_before_playback=number_of_packets_before_playback+1;
    end

    %PLAYBACK----------------------------------------------------------

    %INPUT PROCCESS
    % FROM LINK 3
    if (link_3_Trans==1)
        [push,PLAYBACK,PB_CS]=pushBuffer(PLAYBACK,PB_CS,PLAYBACK_size,link_3_ID,link_3_PR);
    end

    link_3_Trans=0; %The packet has been received from the link at the router

    %OUTPUT PROCESS

    if ((PB_CS/PLAYBACK_size)>=PLAYOUT_PERC)
        Playout_buffer_flag=1;
    end

    if(PB_CS==0)
        Playout_buffer_flag=0;
    end

    if (Playout_buffer_flag==1)
        if (mod(time,(1/PB_Rate))==0)
            [pop_PB,PLAYBACK,PB_CS,PB_ID,PB_PR]=popBuffer(PLAYBACK,PB_CS,PLAYBACK_size);
        end
    end
    PLAYBACK;
    %PLAYBACK--------------------------------------------------------------

    %------------MEASUREMENT----------------------------------------------
    % ID of Packet vs Time of Arival
    if (pop_PB==1)
        % account for the new packet
        Arrival_A_PB=[Arrival_A_PB;[time]];
        Arrival_A_PB_VS_PB_ID=[Arrival_A_PB_VS_PB_ID;[PB_ID,time]];
        After_PB_ID_holder=[After_PB_ID_holder;[PB_ID]];
        number_of_packets_after_playback=number_of_packets_after_playback+1;
        %reset the flag - do not change
        pop_PB=0;
    end

end           %End of simulation (video packets have reached the maximum number)


%------------    PLOTS      ----------------------------------------------
hold on;
figure(1);
plot(Arrival_B_LB, VP_ID_holder, 'kS', Arrival_A_LB,LB_ID_holder ,'m--S');
title('Common diagram for incoming packets and arrival time before and after leaky bucket with SOURCE DELAY=250');
legend('before leaky bucket', 'after leaky bucket');
xlabel({'arrival time measured in slots'});
ylabel({'video packet ids - serial number'});
hold off;
hold on;
figure(2);
plot(Arrival_B_PB, Before_PB_ID_holder, 'gS', Arrival_A_PB,After_PB_ID_holder ,'b--o');
grid on;
title('Common diagram for incoming packets and arrival time before and after playback buffer with PLAYBACK SIZE=600 & INC1=INC2=1/10');
legend('before playback buffer', 'after playback buffer');
xlabel({'arrival time measured in slots'});
ylabel({'video packet ids - serial number'});


disp('----------------------------------------------------------------------------');
disp('TASK A - MEASUREMENTS');
disp('----------------------------------------------------------------------------');
disp('All the subsequent time arrivals of video packets --before the leaky bucket-- Ó1 :');
Arrival_B_LB_VS_VP_ID2 = vec2mat(Arrival_B_LB_VS_VP_ID,10);
%Arrival_B_LB_VS_VP_ID2(Arrival_B_LB_VS_VP_ID2==0)=[];
disp(Arrival_B_LB_VS_VP_ID2);
%xlswrite('ScenarioB3--BeforeLeakyBucket.xlsx',Arrival_B_LB_VS_VP_ID2);

disp('-------------------------------------------------------------------------------------------------');
disp('The number of packets coming out successfully from the generator heading to the leaky bucket is :');
disp(number_of_packets_out_of_generator);
disp('----------------------------------------------------------------------------');
disp('----------------------------------------------------------------------------');
disp('All the subsequent time arrivals of video packets --after the leaky bucket-- Ó2 :');
%Arrival_A_LB_VS_LB_ID = reshape(Arrival_A_LB_VS_LB_ID,22,[],41);
Arrival_A_LB_VS_LB_ID2 = vec2mat(Arrival_A_LB_VS_LB_ID,10);
%Arrival_A_LB_VS_LB_ID2(Arrival_A_LB_VS_LB_ID2==0)=[];
disp(Arrival_A_LB_VS_LB_ID2);
%xlswrite('ScenarioB3--AfterLeakyBucket.xlsx',Arrival_A_LB_VS_LB_ID2);
disp('------------------------------------------------------------------------');
disp('The number of packets coming out successfully from the leaky bucket is :');
disp(number_of_packets_out_of_leaky_bucket);
disp('------------------------------------------------------------------------');
disp('------------------------------------------------------------------------');
disp('All the subsequent time arrivals of video packets --before playback-- Ó3 :');
Arrival_B_PB_VS_link_3_ID = vec2mat(Arrival_B_PB_VS_link_3_ID,10);
%Arrival_B_PB_VS_link_3_ID(Arrival_B_PB_VS_link_3_ID==0)=[];
disp(Arrival_B_PB_VS_link_3_ID);
%xlswrite('ScenarioB3--BeforePlayback.xlsx',Arrival_B_PB_VS_link_3_ID);

disp('------------------------------------------------------------------------');
disp('The number of packets heading successfully to playback is :');
disp(number_of_packets_before_playback);
disp('------------------------------------------------------------------------');
disp('------------------------------------------------------------------------');
disp('All the subsequent time arrivals of packets --after playback-- Ó4 :');
Arrival_A_PB_VS_PB_ID2 = vec2mat(Arrival_A_PB_VS_PB_ID,10);
%Arrival_A_PB_VS_PB_ID2(Arrival_A_PB_VS_PB_ID2==0)=[];
disp(Arrival_A_PB_VS_PB_ID2);
%xlswrite('ScenarioB3--AfterPlayback.xlsx',Arrival_A_PB_VS_PB_ID2);

disp('------------------------------------------------------------------------');
disp('The number of packets coming out successfully from playback is :');
disp(number_of_packets_after_playback);
disp('------------------------------------------------------------------------');
disp('TASK B');
disp('------------------------------------------------------------------------');
lossS1S2=abs(((number_of_packets_out_of_leaky_bucket-number_of_packets_out_of_generator)/number_of_packets_out_of_generator))*100;
lossS1S2=round(lossS1S2,2);
fprintf('The video packet loss between Ó1 and Ó2 is %f%%. ',lossS1S2);
fprintf('\n') ;

lossS2S3=abs(((number_of_packets_before_playback-number_of_packets_out_of_leaky_bucket)/number_of_packets_out_of_leaky_bucket))*100;
lossS2S3=round(lossS2S3,2);
fprintf('The video packet loss between Ó2 and Ó3 is %f%%. ',lossS2S3);
fprintf('\n') ;
lossS2S4=abs(((number_of_packets_after_playback-number_of_packets_out_of_leaky_bucket)/number_of_packets_out_of_leaky_bucket))*100;
lossS2S4=round(lossS2S4,2);
fprintf('The video packet loss between Ó2 and Ó4 is %f%%. ',lossS2S4);
fprintf('\n') ;
lossS3S4=abs(((number_of_packets_after_playback-number_of_packets_before_playback)/number_of_packets_before_playback))*100;
lossS3S4=round(lossS3S4,2);
fprintf('The video packet loss between Ó3 and Ó4 is %f%%. ',lossS3S4);
fprintf('\n') ;
lossS1S4=abs(((number_of_packets_after_playback-number_of_packets_out_of_generator)/number_of_packets_out_of_generator))*100;
lossS1S4=round(lossS1S4,2);
fprintf('The video packet loss between Ó1 and Ó4 is %f%%. ',lossS1S4);
fprintf('\n') ;
disp('------------------------------------------------------------------------');




hold on;
figure(3);
calculated_packets_losses=[lossS1S2; lossS2S3; lossS2S4; lossS3S4; lossS1S4]';
bar(calculated_packets_losses, 0.5, 'r','EdgeColor',[0 .15 .15],'LineWidth',1.9);
set(gca, 'XTickLabel', {'loss S1-S2', 'loss S2-S3', 'loss S2-S4', 'loss S3-S4', 'loss S1-S4'})
xlabel('specified loss between two points');
ylabel('packet loss percentage (%)');
title('Packets losses before, after leaky bucket & before, after playback buffer');


len=min(length(Arrival_B_LB),length(Arrival_B_PB));
jitter_at_S3=Arrival_B_PB;
jitter_at_S3(1:len)=Arrival_B_PB(1:len)-Arrival_B_LB(1:len);

len2=min(length(Arrival_B_LB),length(Arrival_A_PB));
jitter_at_S4=Arrival_A_PB;
jitter_at_S4(1:len2)=Arrival_A_PB(1:len2)-Arrival_B_LB(1:len2);

fprintf('The jitter variance measured in slots at Ó3 is');
fprintf('\n') ;
jitter_at_S3_excluding_zero_jitter_packets = jitter_at_S3(find(jitter_at_S3~=0));
%number_of_packets_with_non_zero_jitter_at_S3=numel(jitter_at_S3_excluding_zero_jitter_packets);
jitter_variance_at_S3=var(jitter_at_S3_excluding_zero_jitter_packets); %variance
jitterS3=sqrt(jitter_variance_at_S3);%standard deviation=sqrt(variance)
jitterS3=jitterS3;
disp(jitterS3);

fprintf('The jitter variance measured in slots at Ó4 is');
fprintf('\n') ;
jitter_at_S4_excluding_zero_jitter_packets = jitter_at_S4(find(jitter_at_S4~=0));
%number_of_packets_with_non_zero_jitter_at_S3=numel(jitter_at_S3_excluding_zero_jitter_packets);
jitter_variance_at_S4=var(jitter_at_S4_excluding_zero_jitter_packets); %variance
jitterS4=sqrt(jitter_variance_at_S4);%standard deviation=sqrt(variance)
jitterS4=jitterS4;
disp(jitterS4);
fprintf('\n') ;
disp('------------------------------------------------------------------------');


hold on;
figure(4);
calculated_jitter=[jitterS3; jitterS4]';
bar(calculated_jitter, 0.8, 'g','EdgeColor',[0 .5 .5],'LineWidth',1.9);
set(gca, 'XTickLabel', {'jitter at S3', 'jitter at S4'});
xlabel('jitter at two points, S3, S4');
ylabel('jitter value measured in slots');
title('jitter values measured in slots before and after playback buffer');

timeElapsed = toc;