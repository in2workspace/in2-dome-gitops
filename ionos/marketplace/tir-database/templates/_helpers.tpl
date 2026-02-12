{{/* charts/database/templates/_helpers.tpl */}}
{{- define "database.name" -}}
database
{{- end -}}

{{- define "database.fullname" -}}
{{ .Release.Name }}-database
{{- end -}}
