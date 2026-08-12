package apiclient

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

type Client struct {
	BaseURL string
	HTTP    *http.Client
	Token   string
}

func New(baseURL string) *Client {
	return &Client{BaseURL: baseURL, HTTP: &http.Client{Timeout: 10 * time.Second}}
}

func (c *Client) Do(ctx context.Context, method, path string, input, output any) error {
	var body *bytes.Reader
	if input == nil { body = bytes.NewReader(nil) } else { encoded, err := json.Marshal(input); if err != nil { return err }; body = bytes.NewReader(encoded) }
	req, err := http.NewRequestWithContext(ctx, method, c.BaseURL+path, body)
	if err != nil { return err }
	req.Header.Set("Accept", "application/json")
	if input != nil { req.Header.Set("Content-Type", "application/json") }
	if c.Token != "" { req.Header.Set("Authorization", "Bearer "+c.Token) }
	resp, err := c.HTTP.Do(req)
	if err != nil { return err }
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 { return fmt.Errorf("api returned %s", resp.Status) }
	if output == nil { return nil }
	return json.NewDecoder(resp.Body).Decode(output)
}
