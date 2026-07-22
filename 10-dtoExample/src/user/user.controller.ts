import { Controller, Get, Post, Query, Param, ParseIntPipe } from '@nestjs/common';
import { UserService } from './user.service';
import type { UserDto } from './dto/user.dto';

@Controller('user')
export class UserController {
  constructor(private readonly usrService: UserService) {}

  @Post('setPass/:pass')
  post(@Param('pass') pass): string{
    return this.usrService.genHash(pass);
  }

  @Get('login/:pass')
  get(@Param('pass') passMaybe):boolean{
    return this.usrService.login(passMaybe);
  }

  @Get()
  getUserJson():UserDto{
    return this.usrService.getUser();
  }
}

