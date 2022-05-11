import { Body, Controller, HttpCode, Post } from '@nestjs/common';
import { PurchaseService } from './purchase.service';
import { PurchaseTokenDto } from './dto';

@Controller('tokens')
export class PurchaseController {
  constructor(private purchaseService: PurchaseService) {}

  @Post()
  @HttpCode(202)
  buy(@Body() params: PurchaseTokenDto) {
    this.purchaseService.process(params);
  }
}
