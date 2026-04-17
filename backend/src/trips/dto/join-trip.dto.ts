import { IsString } from 'class-validator';

export class JoinTripDto {
  @IsString()
  inviteCode: string;
}
