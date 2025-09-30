import { IsIn, IsNotEmpty, IsPhoneNumber, IsString, Length, Matches, MaxLength } from 'class-validator';
import  type { UserRole } from '../user.entity';

export class CreateUserDto {
  @IsString()
  @MaxLength(120)
  @IsNotEmpty()
  name: string;

  @IsString()
  @Length(7, 20)
  // Optional: Iraq numbers validation could be improved; keeping generic
  @Matches(/^[0-9+\- ]+$/)
  phone: string;

  @IsIn([
    'citizen',
    'taxi',
    'tuk_tuk',
    'kia_haml',
    'kia_passenger',
    'stuta',
    'bike',
    'electrician',
    'plumber',
    'ac_tech',
    'blacksmith',
    'restaurant_owner',
    'admin',
    'owner',
  ] as UserRole[])
  role: UserRole;
}
