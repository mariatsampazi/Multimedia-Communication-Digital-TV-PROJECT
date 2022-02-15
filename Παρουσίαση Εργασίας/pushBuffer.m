function [push,buffer,CurrentSize]=pushBuffer(bufferMatrix,CS,MAX,ID,PR)
% CHANGING VARIABLES
% bufferMatrix is the matrix (buffer) of the corresponding selected ellement (i.e. Leaky-bucket, Router, Playback Buffer)
% CS is the current size of the buffer
% FIXED VARIABLES
% MAX is the maximum size of the buffer
% ID is the identifier of the packet
% PR is the priority type of the packet
%FUNCTIONALITY
% -1 wrong function statement.
%  0 full buffer, no packet insert is allowed.  
%  1 packet has been succesfuly inserted at the END of the buffer.
if (nargin~=5)
    push=-1;                %if number of arguments mistaken --> return error code
    buffer=bufferMatrix;
    CurrentSize=CS;
end
CS=CS+1;                    %increasing buffer size
if (CS>MAX)
    CS=CS-1;
    push=0;                 %the buffer is full
else
    push=1;
    bufferMatrix(1,CS)=ID;  %inserting packet 
    bufferMatrix(2,CS)=PR;
end
buffer=bufferMatrix;
CurrentSize=CS;
