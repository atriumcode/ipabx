import { Injectable } from "@nestjs/common"
import type { Extension } from "../extensions/entities/extension.entity"
import type { Trunk } from "../trunks/entities/trunk.entity"

/**
 * Serviço para sincronização com Asterisk Realtime
 * Gerencia tabelas ps_endpoints, ps_auths, ps_aors, sip_users, sip_peers
 */
@Injectable()
export class AsteriskRealtimeService {
  constructor() {}

  /**
   * Sincroniza ramal com PJSIP Realtime
   */
  async syncExtensionPjsip(extension: Extension): Promise<void> {
    const endpointId = `${extension.tenantId}_${extension.numero}`

    // ps_endpoints
    await this.createOrUpdatePsEndpoint({
      id: endpointId,
      tenant_id: extension.tenantId,
      transport: extension.transporte,
      aors: endpointId,
      auth: endpointId,
      context: extension.context,
      disallow: "all",
      allow: extension.codecs,
      direct_media: "no",
      dtmf_mode: extension.dtmfMode,
      force_rport: "yes",
      rtp_symmetric: "yes",
      callerid: extension.callerId || extension.nome,
      mailboxes: extension.mailbox || "",
      language: "pt_BR",
    })

    // ps_auths
    await this.createOrUpdatePsAuth({
      id: endpointId,
      tenant_id: extension.tenantId,
      auth_type: "userpass",
      username: extension.numero,
      password: extension.senha,
    })

    // ps_aors
    await this.createOrUpdatePsAor({
      id: endpointId,
      tenant_id: extension.tenantId,
      max_contacts: extension.maxContacts,
      qualify_frequency: extension.qualifyfreq,
      remove_existing: "yes",
    })

    console.log(`[Asterisk Realtime] Ramal ${extension.numero} sincronizado com PJSIP`)
  }

  /**
   * Sincroniza ramal com SIP Realtime (chan_sip)
   */
  async syncExtensionSip(extension: Extension): Promise<void> {
    await this.createOrUpdateSipUser({
      tenant_id: extension.tenantId,
      name: `${extension.tenantId}_${extension.numero}`,
      defaultuser: extension.numero,
      secret: extension.senha,
      context: extension.context,
      callerid: extension.callerId || extension.nome,
      host: "dynamic",
      type: "friend",
      nat: extension.nat,
      qualify: "yes",
      qualifyfreq: extension.qualifyfreq,
      transport: extension.transporte,
      dtmfmode: extension.dtmfMode,
      directmedia: "no",
      disallow: "all",
      allow: extension.codecs,
      mailbox: extension.mailbox || "",
      language: "pt_BR",
    })

    console.log(`[Asterisk Realtime] Ramal ${extension.numero} sincronizado com SIP`)
  }

  /**
   * Remove ramal do PJSIP Realtime
   */
  async removeExtensionPjsip(extension: Extension): Promise<void> {
    const endpointId = `${extension.tenantId}_${extension.numero}`

    await this.deletePsEndpoint(endpointId)
    await this.deletePsAuth(endpointId)
    await this.deletePsAor(endpointId)

    console.log(`[Asterisk Realtime] Ramal ${extension.numero} removido do PJSIP`)
  }

  /**
   * Remove ramal do SIP Realtime
   */
  async removeExtensionSip(extension: Extension): Promise<void> {
    const name = `${extension.tenantId}_${extension.numero}`
    await this.deleteSipUser(name)

    console.log(`[Asterisk Realtime] Ramal ${extension.numero} removido do SIP`)
  }

  /**
   * Sincroniza tronco com PJSIP Realtime
   */
  async syncTrunkPjsip(trunk: Trunk): Promise<void> {
    const trunkId = `trunk_${trunk.tenantId}_${trunk.id}`

    // ps_endpoints
    await this.createOrUpdatePsEndpoint({
      id: trunkId,
      tenant_id: trunk.tenantId,
      transport: trunk.transporte,
      aors: trunkId,
      auth: trunk.usuario ? trunkId : "",
      context: trunk.context,
      disallow: "all",
      allow: trunk.codecs,
      direct_media: "no",
      dtmf_mode: trunk.dtmfMode,
      from_user: trunk.fromuser || "",
      from_domain: trunk.fromdomain || "",
      send_rpid: trunk.sendrpid,
      language: "pt_BR",
    })

    // ps_auths (se houver autenticação)
    if (trunk.usuario && trunk.senha) {
      await this.createOrUpdatePsAuth({
        id: trunkId,
        tenant_id: trunk.tenantId,
        auth_type: "userpass",
        username: trunk.usuario,
        password: trunk.senha,
      })
    }

    // ps_aors
    await this.createOrUpdatePsAor({
      id: trunkId,
      tenant_id: trunk.tenantId,
      contact: `sip:${trunk.host}:${trunk.porta}`,
      qualify_frequency: 60,
    })

    console.log(`[Asterisk Realtime] Tronco ${trunk.nome} sincronizado com PJSIP`)
  }

  /**
   * Métodos auxiliares (implementação simplificada)
   * Em produção, usar TypeORM com repositories específicos
   */
  private async createOrUpdatePsEndpoint(data: any): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Create/Update ps_endpoint:", data.id)
  }

  private async createOrUpdatePsAuth(data: any): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Create/Update ps_auth:", data.id)
  }

  private async createOrUpdatePsAor(data: any): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Create/Update ps_aor:", data.id)
  }

  private async createOrUpdateSipUser(data: any): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Create/Update sip_user:", data.name)
  }

  private async deletePsEndpoint(id: string): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Delete ps_endpoint:", id)
  }

  private async deletePsAuth(id: string): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Delete ps_auth:", id)
  }

  private async deletePsAor(id: string): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Delete ps_aor:", id)
  }

  private async deleteSipUser(name: string): Promise<void> {
    // TODO: Implementar com TypeORM
    console.log("[Asterisk] Delete sip_user:", name)
  }
}
