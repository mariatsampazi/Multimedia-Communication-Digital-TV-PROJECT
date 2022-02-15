function [pop,buffer,CurrentSize,pop_ID,pop_PR]=popBuffer(bufferMatrix,CS,MAX)
% CHANGING VARIABLES
% bufferMatrix is the matrix (buffer) of the corresponding selected ellement (i.e. Leaky-bucket, Router, Playback Buffer)
% CS is the current size of the buffer
% FIXED VARIABLES
% MAX is the maximum size of the buffer
%FUNCTIONALITY
%------  Placed in variable pop -----
% -1 wrong function statement.
%  0 empty buffer, no pop is allowed.  
%  1 packet has been succesfuly poped from the HEAD of the buffer.
%     pop_ID is the packets ID
%     pop_PR is the packets priority
if (nargin~=3)
    pop=-1;                %if number of arguments mistaken --> return error code
    buffer=bufferMatrix;
    CurrentSize=CS;
    pop_ID=0;
    pop_PR=0;
end
if (CS==0)
    pop=0;                 %the buffer is full
    pop_ID=0;
    pop_PR=0;
else
    pop=1;
    pop_ID=bufferMatrix(1,1);  %inserting packet 
    pop_PR=bufferMatrix(2,1);
    for i=1:CS-1
        bufferMatrix(1,i)=bufferMatrix(1,i+1);
        bufferMatrix(2,i)=bufferMatrix(2,i+1);
    end
    bufferMatrix(1,CS)=0;
    bufferMatrix(2,CS)=0;
    CS=CS-1;  
end
buffer=bufferMatrix;
CurrentSize=CS;
