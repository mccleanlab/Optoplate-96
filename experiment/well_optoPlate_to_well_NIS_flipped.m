well_NIS_flipped = reshape(1:96,12,8)';
well_NIS_flipped(2:2:end,:)=fliplr(well_NIS_flipped(2:2:end,:));
well_NIS_flipped = fliplr(well_NIS_flipped);
well_NIS_flipped = reshape(well_NIS_flipped',1,96)';

well_optoPlate = (1:96)';

well_lookup = [well_optoPlate, well_NIS_flipped]

