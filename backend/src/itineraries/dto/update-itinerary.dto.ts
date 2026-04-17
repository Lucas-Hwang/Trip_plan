import { IsString, IsInt, IsOptional, IsEnum, IsBoolean } from 'class-validator';
import { ItineraryType } from '../../common/entities/itinerary.entity';

export class UpdateItineraryDto {
  @IsInt()
  @IsOptional()
  dayIndex?: number;

  @IsString()
  @IsOptional()
  time?: string;

  @IsString()
  @IsOptional()
  title?: string;

  @IsEnum(ItineraryType)
  @IsOptional()
  type?: ItineraryType;

  @IsInt()
  @IsOptional()
  cost?: number;

  @IsString()
  @IsOptional()
  note?: string;

  @IsInt()
  @IsOptional()
  orderIndex?: number;

  @IsBoolean()
  @IsOptional()
  done?: boolean;
}
