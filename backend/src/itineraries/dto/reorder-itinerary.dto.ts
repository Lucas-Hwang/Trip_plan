import { IsArray, IsString } from 'class-validator';

export class ReorderItineraryDto {
  @IsArray()
  @IsString({ each: true })
  orderedIds: string[];
}
