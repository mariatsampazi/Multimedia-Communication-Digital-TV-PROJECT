function [find,index]=findIndex(bufferMatrix,CS,MAX)
if (nargin~=3)
    find=-1;                %if number of arguments mistaken --> return error code
    index=-2;
end

if (bufferMatrix(2,1)==1)
  index=1;
end

if (bufferMatrix(2,1)==2)
  index=1;
end


if (bufferMatrix(2,1)==3)
      index=1;
end

 find=1;
