import { Test, TestingModule } from '@nestjs/testing';
import { TokensController } from './tokens.controller';
import { PurchaseTokenService } from './purchase-token.service';
import { PurchaseTokenDto } from './purchase-token.dto';

describe('TokensController', () => {
  let purchaseTokenService: PurchaseTokenService;
  let tokensController: TokensController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [TokensController],
      providers: [
        PurchaseTokenService,
        { provide: 'BC_NETWORK', useValue: {} }
      ],
    }).compile();

    purchaseTokenService = app.get<PurchaseTokenService>(PurchaseTokenService);
    tokensController = app.get<TokensController>(TokensController);
  });

  describe('buy', () => {
    const purchaseTokenDto: PurchaseTokenDto = {
      tokens: 100,
      publicKey: '-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxyrn9N7R4yWHtqJPlghp\ne60ZwW7VeBkRDTvixNZI1X1Xk36g0OrXI8F8EkKhv5ny8eZ0823MS7U30OZ8QC2s\nK0CqqJsQuh2+5l6IZf3NA9+spb1m6iBKL49P2037LBMdaOrSpU5qQhnQESgtPQeG\nit5DChdu1qofTbdlGkKPtNgRr+tKDXfQBMhWHEuId7QWZTkMcv0b7FxCPkgISGdZ\nLe+ah9H8yz3+7EB2HOw53/lpKvKmzH37645y9HkXunISRf3oNzmHYqUef4a0ovrZ\nQmATmQE/KodlQ/bI1lvES5XugxtkIIc+EsX+RinKrU5jgFI5ARyvzVywJcjOMmch\nHwIDAQAB',
      correlationId: 'deb98e00-3b4d-45a4-9949-9e4acc7124a8-20211129'
    }

    it('calls PurchaseTokenService', () => {
      const spy: jest.SpyInstance = jest.spyOn(purchaseTokenService, 'process')

      tokensController.buy(purchaseTokenDto);

      expect(spy).toHaveBeenCalled();
    });

    it('returns no response', () => {
      expect(tokensController.buy(purchaseTokenDto)).toBeUndefined();
    });
  });
});
