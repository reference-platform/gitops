{{- define "service.env" -}}
{{- range $name, $value := . }}
- name: {{ $name }}
  {{- if kindIs "map" $value }}
  {{- toYaml $value | nindent 2 }}
  {{- else }}
  value: {{ $value | quote }}
  {{- end }}
{{- end }}
{{- end }}
