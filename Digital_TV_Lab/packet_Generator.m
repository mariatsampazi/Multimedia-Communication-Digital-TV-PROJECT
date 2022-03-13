function [Generator, packet_ID,packet_PR]=packet_Generator(MAX_PR_PERC,MED_PR_PERC,MIN_PR_PERC)
% CHANGING VARIABLES
% packet_ID is the ID of the generated packet
% packet_PR is the PRIORITY of the generated packet
% FIXED VARIABLES
% MAX_PCKT is the number of generated packets
%FUNCTIONALITY
%------  Placed in variable pop -----
% -1 wrong function statement.
% 1 packet has been succesfuly generated.
% packet_ID is the packets ID
% packet_PR is the packets priority
if (nargin~=3)||((MAX_PR_PERC+MED_PR_PERC+MIN_PR_PERC)>1.0) %a8roisma pi9anotiton
    Generator=-1;                %if number of arguments mistaken --> return error code
    packet_ID=0;
    packet_PR=0;
end
pers=rand();
if     (pers<=MIN_PR_PERC)
        packet_PR=1;
        Generator=1;
        packet_ID=-1;
elseif ((pers>MIN_PR_PERC)&&(pers<=(MIN_PR_PERC+MED_PR_PERC)))
        packet_PR=2;
        Generator=1;
        packet_ID=-1;
else
        packet_PR=3;
        Generator=1;
        packet_ID=-1;
end

