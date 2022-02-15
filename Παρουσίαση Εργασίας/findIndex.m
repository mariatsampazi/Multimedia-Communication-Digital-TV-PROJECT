function [find,index]=findIndex(bufferMatrix,CS,MAX)
if (nargin~=3)
    find=-1;                %if number of arguments mistaken --> return error code
    index=-2;
end
flag_1=0;
for k=1:CS
    if (bufferMatrix(2,k)==1)
        index=k;
        flag_1=1;
        break;
    end
end
if (flag_1==0)
    for k=1:CS
        if (bufferMatrix(2,k)==2)
            index=k;
            flag_1=1;
            break;
        end
    end
end
find=1;
if (flag_1==0)
    index=0;
end 