import { Module } from "@nestjs/common"
import { ConfigModule } from "@nestjs/config"
import { AsteriskService } from "./asterisk.service"
import { AsteriskRealtimeService } from "./asterisk-realtime.service"

@Module({
  imports: [
    ConfigModule, // Apenas importa, NÃO coloca ConfigService nos providers
  ],
  providers: [
    AsteriskService,
    AsteriskRealtimeService,
  ],
  exports: [
    AsteriskService,
    AsteriskRealtimeService,
  ],
})
export class AsteriskModule {}
