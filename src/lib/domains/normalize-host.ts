const RESERVED_HOSTS = new Set(['www', 'admin', 'api']);
export function normalizeHost(hostname: string): string {
  return hostname.toLowerCase().replace(/:\\d+$/, '').replace(/\\.$/, '');
}
export function getArtistSlugFromHost(hostname: string, rootDomain: string): string | null {
  const host = normalizeHost(hostname);
  const root = normalizeHost(rootDomain);
  if (host === root || host === `www.${root}`) return null;
  if (!host.endsWith(`.${root}`)) return null;
  const subdomain = host.slice(0, -(root.length + 1));
  if (!subdomain || subdomain.includes('.') || RESERVED_HOSTS.has(subdomain)) return null;
  return subdomain;
}
