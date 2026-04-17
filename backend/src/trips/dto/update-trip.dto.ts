import { IsString, IsDateString, IsOptional } from 'class-validator';

export class UpdateTripDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  destination?: string;

  @IsDateString()
  @IsOptional()
  startDate?: string;

  @IsDateString()
  @IsOptional()
  endDate?: string;
}
