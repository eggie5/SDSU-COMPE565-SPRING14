

function imgComp = motion_comp_inv(ref, residual, motion_vectors)

compensated = motionComp(ref, motion_vectors, 16);
imgComp = uint8(compensated) + uint8(residual);

end