import { Module } from "@nestjs/common"
import { ConfigModule } from "@nestjs/config"
import { AsteriskService } from "./asterisk.service"

@Module({
  imports: [ConfigModule],
  providers: [AsteriskService],
  exports: [AsteriskService],
})
export class AsteriskModule {}
