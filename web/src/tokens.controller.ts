import { Controller, HttpCode, Param, Post } from '@nestjs/common';
import { PurchaseTokenService } from './purchase-token.service';
import { PurchaseTokenDto } from './purchase-token.dto';

@Controller('tokens')
export class TokensController {
  constructor(private readonly purchaseTokenService: PurchaseTokenService) {}

  @Post()
  @HttpCode(202)
  buy(@Param() params: PurchaseTokenDto) {
    this.purchaseTokenService.process(params);
  }
}
