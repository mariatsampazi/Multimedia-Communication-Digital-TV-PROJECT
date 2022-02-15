function [extract,buffer,CurentSize]=extractBuffer(bufferMatrix,CS,MAX,index)

% CHANGING VARIABLES
% bufferMatrix is the matrix (buffer) of the corresponding selected ellement (i.e. Router 1, Router 2)
% CS is the current size of the buffer

% FIXED VARIABLES
% MAX is the maximum size of the buffer


%FUNCTIONALITY
%------  Placed in variable extract -----
% -1 wrong function statement.
%  1 packet has been succesfuly extracted from the buffer.


if (nargin~=4)
    extract=-1;                %if number of arguments mistaken --> return error code
    buffer=bufferMatrix;
    CurentSize=CS;
end


if (CS~=MAX)
    extract=-1;                     %the buffer is NOT full
else
    extract=1;
    for i=index:CS-1
        bufferMatrix(1,i)=bufferMatrix(1,i+1);
        bufferMatrix(2,i)=bufferMatrix(2,i+1);
    end

    bufferMatrix(1,CS)=0;
    bufferMatrix(2,CS)=0;
    CS=CS-1;  
end
buffer=bufferMatrix;
CurentSize=CS;
