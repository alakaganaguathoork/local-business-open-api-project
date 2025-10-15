# Specify the load balancer scheme as internet-facing to create a public-facing Network Load Balancer (NLB)
{{- define "app.eks.annotations.lb" -}}
{{- if .Values.services.loadbalancer.internal }}
service.beta.kubernetes.io/aws-load-balancer-scheme: internal
{{- else }}
service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
{{- end }}
{{- end }}

# Specify security groups for a service
{{- define "app.eks.annotations.sg" -}}
{{- $raw := (.Files.Get ".sg-ids.output" | default "") | trim -}}
{{- if $raw }}
  {{- $clean := $raw
      | replace "[" ""
      | replace "]" ""
      | replace "\"" ""
      | replace " " ""
      | replace "\n" ""
      | replace "\r" "" -}}
  {{- $items := splitList "," $clean -}}
service.beta.kubernetes.io/aws-load-balancer-security-groups: "{{ join "," $items }}"
{{- end }}
{{- end }}


