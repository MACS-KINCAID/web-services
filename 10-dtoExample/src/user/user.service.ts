import { Injectable } from '@nestjs/common';
import { UserDto } from './dto/user.dto';
import bcrypt from "bcrypt";


@Injectable()
export class UserService {

  user : UserDto = {
    "email":"",
    "password":""
  };

  genHash(passwd:string):string{
    const saltRounds = 10;
    let hash = bcrypt.hashSync(passwd, saltRounds);
    this.user.password = hash;
    return hash;
  }

  login(passwdMaybe:string):boolean{
      return bcrypt.compareSync(passwdMaybe, this.user.password);
  }

  getUser():UserDto{
    return this.user;
  }
}

