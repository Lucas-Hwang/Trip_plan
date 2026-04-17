import { IsString } from 'class-validator';

export class CreateVoteDto {
  @IsString()
  option: string;
}
