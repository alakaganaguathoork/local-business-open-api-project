data "http" "argocd_values" {
  for_each = local.helm_releases

  url             = each.value.values_file_url
  request_headers = { Accept = "text/yaml" }
}

resource "helm_release" "argocd" {
  for_each = local.helm_releases

  name             = each.value.name
  namespace        = each.value.namespace
  repository       = each.value.repository
  chart            = each.value.chart
  create_namespace = try(each.value.create_namespace, true)
  cleanup_on_fail  = try(each.value.cleanup_on_fail, true)
  atomic           = try(each.value.atomic, true)
  force_update     = try(each.value.force_update, true)
  version          = try(each.value.version, null)
  values           = [data.http.argocd_values[each.key].response_body]
}
