{{/* charts/portal/templates/_helpers.tpl */}}
{{- define "portal.name" -}}
portal
{{- end -}}

{{- define "portal.fullname" -}}
{{ .Release.Name }}-portal
{{- end -}}
