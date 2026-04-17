import { IsString, IsDateString } from 'class-validator';

export class CreateTripDto {
  @IsString()
  title: string;

  @IsString()
  destination: string;

  @IsDateString()
  startDate: string;

  @IsDateString()
  endDate: string;
}
