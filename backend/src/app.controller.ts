import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  root() {
    return { ok: true, service: 'trip-planner-api' };
  }

  @Get('health')
  health() {
    return this.appService.health();
  }
}
