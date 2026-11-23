function log = present_motion(window, g, ifi, startDeg, finishDeg, durationSec, sigmaDeg)
% PRESENT_MOTION Precompute angular Gaussian frames; skip stale frames if late.
% Position is selected for the next retrace using elapsed time, not accumulated steps.
validateattributes(durationSec, {'numeric'}, {'real','finite','positive','scalar'});
n = max(1, round(durationSec/ifi));
textures = zeros(1,n+1); rects = zeros(n+1,4); positions = zeros(n+1,2);
% Textures are owned by the caller's display cleanup if precomputation fails.
for k = 0:n
    check_escape;
    positions(k+1,:) = linear_trajectory(startDeg,finishDeg,k*ifi,n*ifi);
    [im,rects(k+1,:)] = gaussian_blob_image(g,positions(k+1,:),sigmaDeg,1);
    textures(k+1) = Screen('MakeTexture',window,im);
end
log = struct('requestedSec',durationSec,'plannedSec',n*ifi, ...
    'onsetSec',[],'positionDeg',[],'sampleSec',[],'missedSec',[],'offsetSec',NaN);
k = 1; startVbl = NaN; vbl = NaN;
while true
    check_escape;
    Screen('FillRect',window,0.5);
    Screen('DrawTexture',window,textures(k),[],rects(k,:));
    draw_fixation(window,g);
    when = 0;
    if ~isnan(vbl), when = vbl+0.5*ifi; end
    [vbl,onset,~,missed] = Screen('Flip',window,when);
    if isnan(startVbl), startVbl = vbl; end
    log.onsetSec(end+1,1) = onset;
    log.positionDeg(end+1,:) = positions(k,:);
    log.sampleSec(end+1,1) = (k-1)*ifi;
    log.missedSec(end+1,1) = missed;
    if k == n+1, break; end
    k = min(n+1, max(k+1, round((vbl-startVbl)/ifi)+2));
end
% Show the endpoint for one refresh, then remove it.
Screen('FillRect',window,0.5); draw_fixation(window,g);
[~,log.offsetSec] = Screen('Flip',window,vbl+0.5*ifi);
Screen('Close',textures);
end
