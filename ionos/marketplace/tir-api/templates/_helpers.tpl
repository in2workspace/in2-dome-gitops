{{/* charts/api/templates/_helpers.tpl */}}
{{- define "api.name" -}}
api
{{- end -}}

{{- define "api.fullname" -}}
{{ .Release.Name }}-api
{{- end -}}
