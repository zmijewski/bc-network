import { Injectable } from '@nestjs/common';
import { PurchaseTokenDto } from './purchase-token.dto';

@Injectable()
export class PurchaseTokenService {
  process(params: PurchaseTokenDto): void {
    // connect to queue and send request
  }
}
