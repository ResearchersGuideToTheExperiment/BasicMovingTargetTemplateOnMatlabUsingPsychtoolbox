function positionDeg = linear_trajectory(startDeg, finishDeg, elapsedSec, durationSec)
% LINEAR_TRAJECTORY Constant speed in angular coordinates; clamp at endpoints.
validateattributes(startDeg, {'numeric'}, {'real','finite','size',[1 2]});
validateattributes(finishDeg, {'numeric'}, {'real','finite','size',[1 2]});
validateattributes(elapsedSec, {'numeric'}, {'real','finite','nonnegative','scalar'});
validateattributes(durationSec, {'numeric'}, {'real','finite','positive','scalar'});
fraction = min(1, elapsedSec/durationSec);
positionDeg = startDeg + fraction*(finishDeg-startDeg);
end
