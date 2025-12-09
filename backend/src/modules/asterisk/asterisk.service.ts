import { Injectable, type OnModuleInit } from "@nestjs/common"
import { ConfigService } from "@nestjs/config"

/**
 * Serviço de integração com Asterisk AMI/ARI
 */
@Injectable()
export class AsteriskService implements OnModuleInit {
  private amiConnected = false

  constructor(private configService: ConfigService) {}

  async onModuleInit() {
    console.log("[Asterisk] Inicializando conexão com Asterisk...")
    // TODO: Implementar conexão AMI
  }

  /**
   * Verifica se está conectado ao AMI
   */
  isConnected(): boolean {
    return this.amiConnected
  }

  /**
   * Retorna status do Asterisk
   */
  async getStatus() {
    return {
      connected: this.amiConnected,
      version: "Asterisk 20+",
      uptime: 0,
    }
  }

  /**
   * Lista canais ativos
   */
  async getActiveChannels() {
    // TODO: Implementar via AMI
    return []
  }

  /**
   * Origina uma chamada
   */
  async originateCall(extension: string, destination: string) {
    console.log(`[Asterisk] Originando chamada de ${extension} para ${destination}`)
    // TODO: Implementar via AMI
  }
}
