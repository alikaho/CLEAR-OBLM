function beam_loss_dist = Convert_fiber_to_beam_dist(app, beam_loss_dist_fiber)
% Function converts the distance along the fiber where the beam is lost to
% a distance along the beamline using the linear calibration analysis done
% in script: BTV_screens_analysis_CFD.m
    beam_loss_dist = 1/app.gradient * (beam_loss_dist_fiber - app.offset);
end