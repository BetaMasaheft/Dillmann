/**
 * Pure read-only request policy — no Cypress hooks or mutable state.
 *
 * Default-deny for app hosts: PUT/PATCH/DELETE are always writes, and a POST
 * is a write unless it is a session login/logout. Dillmann's search and the
 * new-entry duplicate check (/api/Dillmann/otherlemmas) are GETs, so no POST
 * path allowlist is needed; add one here only for an observed, verified
 * endpoint — never for a hypothetical URL.
 */

/** POST paths that are known non-write endpoints. Currently none. */
export const ALLOWED_POST_PATHS = []

/**
 * eXist login-module request params. The #login-nav form has no action
 * attribute, so login/logout POST to whatever page is open — they can only be
 * recognised by their body, which must contain nothing but these params.
 * (An empty password value is fine: the dev stack logs in admin without one.)
 */
const SESSION_PARAM_NAMES = ['user', 'password', 'duration', 'logout']

/** Hosts whose data this policy protects; read-only.js adds the baseUrl host. */
export const DEFAULT_APP_HOSTNAMES = ['betamasaheft.eu']

const WRITE_METHODS = ['POST', 'PUT', 'PATCH', 'DELETE']

// Relative URLs (e.g. from cy.request) resolve against this sentinel origin
// and are treated as app requests.
const RELATIVE_URL_BASE = 'http://app.invalid'

function bodyParamNames (body) {
  if (typeof body === 'string' && body !== '') {
    return [...new URLSearchParams(body).keys()]
  }
  if (body && typeof body === 'object') {
    return Object.keys(body)
  }
  return []
}

export function isSessionPost (body) {
  const names = bodyParamNames(body)

  if (names.length === 0 || !names.every((name) => SESSION_PARAM_NAMES.includes(name))) {
    return false
  }

  return names.includes('logout') ||
    (names.includes('user') && names.includes('password'))
}

export function isDataWriteRequest (req, appHostnames = DEFAULT_APP_HOSTNAMES) {
  const method = req.method.toUpperCase()

  if (!WRITE_METHODS.includes(method)) {
    return false
  }

  const url = new URL(req.url, RELATIVE_URL_BASE)
  const isAppHost = url.hostname === 'app.invalid' ||
    appHostnames.some((hostname) =>
      url.hostname === hostname || url.hostname.endsWith('.' + hostname))

  if (!isAppHost) {
    return false
  }

  if (method !== 'POST') {
    return true
  }

  if (ALLOWED_POST_PATHS.some((pattern) => pattern.test(url.pathname))) {
    return false
  }

  return !isSessionPost(req.body)
}
