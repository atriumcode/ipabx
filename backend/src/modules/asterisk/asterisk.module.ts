import { Module } from "@nestjs/common"
import { AsteriskService } from "./asterisk.service"
import { AsteriskRealtimeService } from "./asterisk-realtime.service"

@Module({
  imports: [], // ← REMOVER ConfigModule
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
