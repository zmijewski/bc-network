import { Module } from '@nestjs/common';
import { TokensController } from './tokens.controller';
import { PurchaseTokenService } from './purchase-token.service';

@Module({
  imports: [],
  controllers: [TokensController],
  providers: [PurchaseTokenService],
})
export class AppModule {}
